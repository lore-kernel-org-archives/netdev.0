From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 10:12:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB6D877.3D5489DA@us.ibm.com>
References: <200210231218.18733.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl> <1035379308.5950.3.camel@rth.ninka.net> <200210231542.48673.roy@karlsbakk.net> <20021023170102.GA5302@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Roy Sigurd Karlsbakk <roy@karlsbakk.net>,
   "David S. Miller" <davem@rth.ninka.net>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:

> I still refuse to believe that a 1.8GHz Pentium4 can only checksum
> 250megabits/second. MD Raid5 does better and they probably don't use a
> checksum as braindead as that used by TCP.
> 
> If the checksumming is not the problem, the copying is, which would be a
> weakness of your hardware. The function profiled does both the copying and
> the checksumming.

Yep, its not so much the checksumming as the fact that this is
done over each byte of data and copied.

thanks,
Nivedita
