From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] enhanced version of net_random()
Date: Sun, 22 Aug 2004 17:04:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040822170414.3ecab1e5.ak@suse.de>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
	<20040820175952.GI5806@certainkey.com>
	<20040820185956.GV8967@schnapps.adilger.int>
	<Pine.LNX.4.53.0408201518250.25319@chaos>
	<20040820124823.071ac1d9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: root@chaos.analogic.com, adilger@clusterfs.com, jlcooke@certainkey.com,
        shemminger@osdl.org, alan@lxorguk.ukuu.org.uk, tytso@mit.edu,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040820124823.071ac1d9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Aug 2004 12:48:23 -0700
"David S. Miller" <davem@redhat.com> wrote:

> > I wouldn't suggest converting it to 'C' because the rotation
> > takes many CPU instructions when one tries to do the test, shift,
> > and OR in 'C',
> 
> You only need 2 'shifts' and an 'or' to do a rotate in C.
> No tests are needed.

gcc is clever enough to detect the common C patterns for rotate
and generate a real ROL when the CPU supports it.

-Andi
