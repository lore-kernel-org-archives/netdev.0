From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 15:42:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210231542.48673.roy@karlsbakk.net>
References: <200210231218.18733.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl> <1035379308.5950.3.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@rth.ninka.net>, bert hubert <ahu@ds9a.nl>
In-Reply-To: <1035379308.5950.3.camel@rth.ninka.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The e1000 can very well do hardware checksumming on transmit.
>
> The missing piece of the puzzle is that his application is not
> using sendfile(), without which no transmit checksum offload
> can take place.

As far as I've understood, sendfile() won't do much good with large files. Is 
this right?

We're talking of 3-6GB files here ...

roy
-- 
Roy Sigurd Karlsbakk, Datavaktmester
ProntoTV AS - http://www.pronto.tv/
Tel: +47 9801 3356

Computers are like air conditioners.
They stop working when you open Windows.
