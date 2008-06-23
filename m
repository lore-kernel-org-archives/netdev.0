From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: add support for IFLA_NET_NS_PID in ip link v2
Date: Mon, 23 Jun 2008 09:02:12 -0700
Message-ID: <20080623090212.760589de@extreme>
References: <20080620090734.144305411@theryb.frec.bull.fr>
	<20080620092109.551812772@theryb.frec.bull.fr>
	<485F59ED.2080404@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <benjamin.thery@bull.net>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49794 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759910AbYFWQEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 12:04:13 -0400
In-Reply-To: <485F59ED.2080404@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jun 2008 10:08:13 +0200
Daniel Lezcano <dlezcano@fr.ibm.com> wrote:

> Benjamin Thery wrote:
> > Ah, ah, of course I forgot to refresh the patch before sending it. :)
> > There was still a small typo in the patch: a '}' was put instead of 
> > a '|' in 'ip link' usage string. 
> > 
> > Here is the updated patch.
> > Sorry for this.
> > 
> > Benjamin
> > 
> > Description:
> > ------------
> > 
> > This patch adds support for the IFLA_NET_NS_PID type. It is used to 
> > move network devices between network namespaces.
> > 
> > The syntax is: 
> > ip link set DEVICE netns PID
> > 
> > PID is the pid of a process in the target network namespace.
> > 
> > (Daniel Lezcano is the original author). 
> > 
> > Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> > Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> 
> Hi Stephen,
> 
> we posted this patch several times and we had no response.
> I suppose you are very busy and you had no time to answer.
> Can you briefly tell us what do you plan to do with this patch ?
> 
> 
> Thanks
>    -- Daniel
> 
I am doing a new release. It is in the list of things to go in.
But was holding off until other issues resolved. It will go in today.
