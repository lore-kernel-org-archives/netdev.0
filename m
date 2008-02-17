From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: RESEND, HTB(?) softlockup, vanilla 2.6.24
Date: Sun, 17 Feb 2008 02:03:33 +0200
Message-ID: <20080216235419.M80874@visp.net.lb>
References: <20080213081318.M90354@visp.net.lb> <47B69824.4030405@gmail.com> <20080216102502.M41110@visp.net.lb> <20080216204519.GA2739@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:36392 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbYBQADx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 19:03:53 -0500
In-Reply-To: <20080216204519.GA2739@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Server is fully redundant now, so i apply patches (but i apply both, probably 
it will make system more reliable somehow) and i enable required debug 
options in kernel. So i will try to catch this bug few more times, probably 
if it will generate more detailed info over netconsole it will be useful.

Is there any project to dump console messages/kernel dump to disk? For 
example such issues related to networking, and i guess netconsole doesn't 
always work, especially when network driver is crashed, but tech's on 
location told there is some messages running non-stop on the screen. Probably 
some generic code writing such data over x86 INT 13 (or even kernel dump?) to 
separate partition will be useful to debug this problem. I know there is some 
3rd party patches(for example LKCD), but i prefer to not apply them to not 
add more bugs.

I notice some code in MTD(CONFIG_MTD_OOPS), but i am not sure it is correct 
and will work if i will setup MTD emulation for block device.
That just idea.

On Sat, 16 Feb 2008 21:45:19 +0100, Jarek Poplawski wrote
> On Sat, Feb 16, 2008 at 12:25:31PM +0200, Denys Fedoryshchenko wrote:
> > Thanks, i will try it.
> > You think lockdep can be buggy?
> 
> Just like every code... But the main reason is it has quite 
> meaningful overhead, so could be right "in production" only after 
> lockups happen. But if it doesn't report anything anyway...
> 
> Your report shows there are quite long paths of calls during softirqs
> with some actions (ipt + mirred here?) and qdiscs, so if I'm not 
> wrong with this stack problem, this would need some optimization. 
> And, of course, there could be some additional bugs involved around too:
> otherwise it seems this should happen more often. But I don't expect
> you would try to debug this on your servers, so I hope, it simply 
> will be found BTW some day...
> 
> Regards,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

