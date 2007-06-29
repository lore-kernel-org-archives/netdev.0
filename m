From: Jens Stroebel <drifter@bcsoft.de>
Subject: Re: 2.6.21.5+1small patch: not blocking
Date: Fri, 29 Jun 2007 17:44:56 +0200
Message-ID: <468528F8.8050806@bcsoft.de>
References: <4683F923.80508@bcsoft.de> <20070628213050.GB4233@electric-eye.fr.zoreil.com> <4684F898.80204@bcsoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev list <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:56951 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933466AbXF2PpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 11:45:07 -0400
In-Reply-To: <4684F898.80204@bcsoft.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jens Stroebel wrote:
> Francois Romieu wrote:
>> [...]

>> It may help and/or accelerate things if you can narrow the fix(es) in
>> the current r8169 serie.

> Instead, I built 2.6.21.5+[a patch I snatched from a mail communication
> you had on 2007-06-20
> (Msg-ID: <20070620211530.GA10042@electric-eye.fr.zoreil.com> )].
> I will attach it with this mail, as it is really small and you don't
> have to dig around to know what I'm talking about.
> 
> As I am no kernel-developer, I am not sure there are no undesired side
> effects by applying this patch to this kernel; if you think there are
> (could/should be), it would be nice if you could state that, so I'd
> refrain from testing with this combination.

Following up to myself:

It seems like the patch is able to change things in a way which makes
the machine lock up hard. Pity that, looked so promising at first...

		greets,
		   jens
-- 
drifter@bcsoft.de
			23.....56.......drifting
By caffeine alone I set my mind in motion, By the beans of Java
do thoughts acquire speed,  hands acquire shaking,  the shaking
becomes a warning, By caffeine alone do I set my mind in motion
