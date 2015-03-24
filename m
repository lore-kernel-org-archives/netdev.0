From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH]: iproute2: enhance enforcement of ifconfig compatible
 address labels and allow non-compatible ones with -force
Date: Tue, 24 Mar 2015 15:11:14 -0700
Message-ID: <20150324151114.7168de0b@urahara>
References: <4edec6f657e24e98b938c3ad76b54625@BRMWP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vadim Kochan <vadim4j@gmail.com>
To: Joe Harvell <joe.harvell@tekcomms.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35089 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751842AbbCXWLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:11:18 -0400
In-Reply-To: <4edec6f657e24e98b938c3ad76b54625@BRMWP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Mar 2015 17:55:02 +0000
Joe Harvell <joe.harvell@tekcomms.com> wrote:

> The ip addr command today rejects address labels that would break 
> ifconfig.  However, it allows some labels which still break it. Enhance 
> enforcement to reject all known incompatible labels, and allow the 
> existing -force option to allow someone to use a label even if it is not 
> ifconfig compatible
> 
> Make existing -force option of ip addr add skip enforcment of ifconfig 
> compatible address labels.
> Change enforcement to properly reject labels that do begin with 
> <devname> but are followed by a string that does not begin with colon.
> 
> 
> The following changes since commit 4612d04d6b8f07274bd5d0688f717ccc189499ad:
> 
>    tc class: Show class names from file (2015-03-15 12:27:40 -0700)
> 
> are available in the git repository at:
> 
>    git@github.com:jharvell/iproute2.git addr-label-noncompat
> 
> for you to fetch changes up to 6a1d09e93ae1fb4f7f1cd5981813af918e8efc88:

Not really enthusiastic about this. It seems to introduce more issues
and I don't consider it a big issue. If user is creating labels with
ip and it breaks ifconfig, it is really a case of shooting themselves
in the foot; or the fact that ifconfig needs to die (or get fixed).
