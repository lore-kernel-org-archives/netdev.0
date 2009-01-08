From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: RFC: Network privilege separation.
Date: Thu, 8 Jan 2009 10:43:05 +0000
Message-ID: <20090108104305.7b271053@lxorguk.ukuu.org.uk>
References: <1231307334-9542-1-git-send-email-michael@laptop.org>
	<87mye2yg8a.fsf@basil.nowhere.org>
	<20090108023111.GJ3164@didacte.laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:41358 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751010AbZAHKmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 05:42:50 -0500
In-Reply-To: <20090108023111.GJ3164@didacte.laptop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Conclusion: so far as I can see, RLIMIT_NETWORK is, in every way, a smaller
> expansion of the end user's trusted code base and should therefore be preferred
> in comparison netfilter-based solutions for process-level network privilege
> separation tasks. Do you see things differently?

If you have the same uid then you can just use ptrace to drive another
task with that uid to do the creations for you. Chances are you can also
attack shared executable files (eg that uids .bashrc)

That to me says controlling network access is only useful as part of a
more fine grained and general purpose interface. We already have that
interface in the form of things like SELinux. We already have systems
actively using it to control stuff like which ports are accessed by some
services.

Alan
