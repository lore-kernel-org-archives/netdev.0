From: David Greaves <david@dgreaves.com>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it, anyways?
 [compare with e.g. NBD + MD raid])
Date: Mon, 13 Aug 2007 09:03:30 +0100
Message-ID: <46C01052.4050708@dgreaves.com>
References: <200708121335.17267.a1426z@gawab.com> <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr> <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm> <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr> <20070812174549.GA2915@teal.hq.k1024.org> <46BFB6BB.80406@steeleye.com> <Pine.LNX.4.64.0708122016100.22470@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Clements <paul.clements@steeleye.com>,
	Jan Engelhardt <jengelh@computergmbh.de>,
	Al Boldi <a1426z@gawab.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-raid@vger.kernel.org
To: david@lang.hm
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0708122016100.22470@asgard.lang.hm>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

david@lang.hm wrote:
> per the message below MD (or DM) would need to be modified to work 
> reasonably well with one of the disk components being over an unreliable 
> link (like a network link)
> 
> are the MD/DM maintainers interested in extending their code in this 
> direction? or would they prefer to keep it simpler by being able to 
> continue to assume that the raid components are connected over a highly 
> reliable connection?
> 
> if they are interested in adding (and maintaining) this functionality 
> then there is a real possibility that NBD+MD/DM could eliminate the need 
> for DRDB. however if they are not interested in adding all the code to 
> deal with the network type issues, then the argument that DRDB should 
> not be merged becouse you can do the same thing with MD/DM + NBD is 
> invalid and can be dropped/ignored
> 
> David Lang

As a user I'd like to see md/nbd be extended to cope with unreliable links.
I think md could be better in handling link exceptions. My unreliable memory 
recalls sporadic issues with hot-plug leaving md hanging and certain lower level 
errors (or even very high latency) causing unsatisfactory behaviour in what is 
supposed to be a fault 'tolerant' subsystem.


Would this just be relevant to network devices or would it improve support for 
jostled usb and sata hot-plugging I wonder?

David

