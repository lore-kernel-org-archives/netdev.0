From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC] enhanced version of net_random()
Date: Sat, 21 Aug 2004 00:55:01 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1093046100.31904.0.camel@localhost.localdomain>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
	 <20040820175952.GI5806@certainkey.com>
	 <20040820185956.GV8967@schnapps.adilger.int>
	 <1093037055.10063.192.camel@krustophenia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andreas Dilger <adilger@clusterfs.com>,
	Jean-Luc Cooke <jlcooke@certainkey.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@redhat.com>,
	"Theodore Ts'o" <tytso@mit.edu>, netdev@oss.sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268717AbUHUA56@vger.kernel.org>
To: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <1093037055.10063.192.camel@krustophenia.net>
List-Id: netdev.vger.kernel.org

On Gwe, 2004-08-20 at 22:24, Lee Revell wrote:
> One problem is that AIUI, we incur this overhead even if a hardware RNG
> is present.  This does not seem right.  Hardware RNGs are increasingly
> common, Linux supports hardware RNGs from AMD, Intel, and VIA.

Hardware RNG's are actually fairly slow and thus are better as sources
to perturb a PRNG.
