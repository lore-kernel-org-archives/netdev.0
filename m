From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] enhanced version of net_random()
Date: Fri, 20 Aug 2004 12:48:23 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040820124823.071ac1d9.davem@redhat.com>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
	<20040820175952.GI5806@certainkey.com>
	<20040820185956.GV8967@schnapps.adilger.int>
	<Pine.LNX.4.53.0408201518250.25319@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: adilger@clusterfs.com, jlcooke@certainkey.com, shemminger@osdl.org,
	alan@lxorguk.ukuu.org.uk, tytso@mit.edu, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268005AbUHTTsw@vger.kernel.org>
To: root@chaos.analogic.com
In-Reply-To: <Pine.LNX.4.53.0408201518250.25319@chaos>
List-Id: netdev.vger.kernel.org

On Fri, 20 Aug 2004 15:22:09 -0400 (EDT)
"Richard B. Johnson" <root@chaos.analogic.com> wrote:

> The attached code will certainly work on Intel machines. It is
> in the public domain, having been modified by myself to produce
> a very long sequence...

How long a period does it have?  The one we're adding to the
networking has one which is 2^88.

> I wouldn't suggest converting it to 'C' because the rotation
> takes many CPU instructions when one tries to do the test, shift,
> and OR in 'C',

You only need 2 'shifts' and an 'or' to do a rotate in C.
No tests are needed.
