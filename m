From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 11 Nov 2009 15:19:54 -0500
Message-ID: <81bfc67a0911111219m1efff30cr3186987f9dbb3d4d@mail.gmail.com>
References: <81bfc67a0910310721p21046931o9b512cfd0a8a7acb@mail.gmail.com>
	 <200910311944.35922.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Frans Pop <elendil@planet.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758298AbZKKUTu@vger.kernel.org>
In-Reply-To: <200910311944.35922.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

not to be impatient or ungrateful, but has anyone had time to look at
this? will I be able to upgrade to 31.6? will 32.0 work?

On Sat, Oct 31, 2009 at 1:44 PM, Frans Pop <elendil@planet.nl> wrote:
> Adding netdev in CC. Original message + attachments follow.
>
> =========
> so ever since arch rolled out 2.6.31.x I've been having problems with
> my network (again) where I've been losing a large amount of packets
> (just testing with mtr somewhere between 30/50%). first I figured it
> was the same problem as I had in 2.6.30.x (and maybe it is?) but that
> appeared to get fixed. when I started bisecting the bug wasn't
> apparent in 2.6.31.0 but I knew for sure it was in .5 (I couldn't
> remember if I had noticed it again in .3)
>
> I'm attaching the bisection log and a 'good' dmesg output.
>
> c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9 is the first bad commit
>
> I'm not going to pretend to understand why this patch is breaking my
> networking but between bisection and testing it appears to be... I've
> never bisected before and I'm definitely not a kernel hacker (I can
> barely read C).
>
> I should also note that the wireshark dump here
> http://bugzilla.kernel.org/show_bug.cgi?id=13835 is related to this.
> and if it's not the same bug then possibly a new one should be opened.
>
> P.S. I'm not subscribed to the list please CC me
>
> Caleb Cushing
> http://xenoterracide.blogspot.com
>
>



-- 
Caleb Cushing

http://xenoterracide.blogspot.com
