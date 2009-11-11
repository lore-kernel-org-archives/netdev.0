From: Frans Pop <elendil@planet.nl>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 11 Nov 2009 23:05:53 +0100
Message-ID: <200911112305.54824.elendil@planet.nl>
References: <81bfc67a0910310721p21046931o9b512cfd0a8a7acb@mail.gmail.com> <81bfc67a0911111219m1efff30cr3186987f9dbb3d4d@mail.gmail.com> <878wecka3g.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Caleb Cushing <xenoterracide@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759484AbZKKWFw@vger.kernel.org>
In-Reply-To: <878wecka3g.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 November 2009, Andi Kleen wrote:
> Caleb Cushing <xenoterracide@gmail.com> writes:
> >> I'm attaching the bisection log and a 'good' dmesg output.
> >>
> >> c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9 is the first bad commit
>
> Just gives fatal: bad object c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9
> here on a standard Linus linux-2.6 tree.

Looks to be a commit from a stable update:

commit c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9
Author: Alan Stern <stern@rowland.harvard.edu>
Date:   Tue Sep 1 11:38:34 2009 -0400

    usb-serial: change referencing of port and serial structures

    commit 41bd34ddd7aa46dbc03b5bb33896e0fa8100fe7b upstream.

Cheers,
FJP
