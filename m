From: "ravinandan arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Submission #3  for S2io 10GbE driver
Date: Fri, 12 Mar 2004 13:55:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002f01c4087c$c1df99c0$6610100a@S2IOtech.com>
References: <4040F866.9040200@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, "'Stephen Hemminger'" <shemminger@osdl.org>,
        "'Christoph Hellwig'" <hch@infradead.org>,
        <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Leonid Grossman'" <leonid.grossman@s2io.com>
In-Reply-To: <4040F866.9040200@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,
Regarding comment #15, we don't think locking is required, because we
just reflect what ever the statistics block is reflecting at the current
moment.

Thanks,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Saturday, February 28, 2004 12:22 PM
To: Leonid Grossman
Cc: netdev@oss.sgi.com; 'Stephen Hemminger'; 'Christoph Hellwig';
'ravinandan arakali'; raghavendra.koushik@s2io.com
Subject: Re: Submission #3 for S2io 10GbE driver

Looking a lot better.  A few merge issues remain, and some operational 
ones as well.  There are 39 issues in this review, but IMO they are 
mostly minor issues that don't require much thought or work.


Comments:

<snipped>

15) does s2io_get_stats need locking?

<snipped>
