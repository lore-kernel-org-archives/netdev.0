From: Ben Greear <greearb@candelatech.com>
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Tue, 27 Jun 2006 10:19:23 -0700
Message-ID: <44A1689B.7060809@candelatech.com>
References: <20060609210625.144158000@localhost.localdomain>	<20060626134711.A28729@castle.nmd.msu.ru>	<449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru>	<44A00215.2040608@fr.ibm.com>	<20060627131136.B13959@castle.nmd.msu.ru>	<44A0FBAC.7020107@fr.ibm.com>	<20060627133849.E13959@castle.nmd.msu.ru>	<44A1149E.6060802@fr.ibm.com>	<m1sllqn7cb.fsf@ebiederm.dsl.xmission.com>	<20060627160241.GB28984@MAIL.13thfloor.at> <m1psgulf4u.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrey Savochkin <saw@swsoft.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	sam@vilain.net, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161170AbWF0RU2@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1psgulf4u.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Herbert Poetzl <herbert@13thfloor.at> writes:
> 
> 
>>On Tue, Jun 27, 2006 at 05:52:52AM -0600, Eric W. Biederman wrote:
>>
>>>Inside the containers I want all network devices named eth0!
>>
>>huh? even if there are two of them? also tun?
>>
>>I think you meant, you want to be able to have eth0 in
>>_more_ than one guest where eth0 in a guest can also
>>be/use/relate to eth1 on the host, right?
> 
> 
> Right I want to have an eth0 in each guest where eth0 is
> it's own network device and need have no relationship to
> eth0 on the host.

How does that help anything?  Do you envision programs
that make special decisions on whether the interface is
called eth0 v/s eth151?

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
