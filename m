From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: Linux 2.6.7
Date: Thu, 17 Jun 2004 08:56:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617065607.GA11999@louise.pinerecords.com>
References: <Pine.LNX.4.58.0406152253390.6392@ppc970.osdl.org> <20040616111329.GA1571@louise.pinerecords.com> <20040616121850.GO12308@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: viro@parcelfarce.linux.theplanet.co.uk
Content-Disposition: inline
In-Reply-To: <20040616121850.GO12308@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Jun-16 2004, Wed, 13:18 +0100
viro@parcelfarce.linux.theplanet.co.uk <viro@parcelfarce.linux.theplanet.co.uk> wrote:

> > 2.6.7's airo.ko (unlike 2.6.6's) won't allow the user to set
> > ESSID via "echo myessid >/proc/driver/aironet/ethX/SSID".
> > 
> > Changes like this shouldn't probably be made in the middle
> > of a stable series.
> 
> Changes like this are called bugs.  The thing is, original variant of
> function (actually, both read and write) was also buggy and trivially
> exploitable, so fixing it was needed.  Fscking it up was not, obviously.

Sure, I just assumed somebody had done this on purpose.

> Fix follows; see if it works for you.

Works for me, thanks.

-- 
Tomas Szepe <szepe@pinerecords.com>
