From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 16:05:20 -0400
Message-ID: <200505171605.21093.jheffner@psc.edu>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site> <200505171531.37167.jheffner@psc.edu> <428A4B74.4050503@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <428A4B74.4050503@us.ibm.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 17 May 2005 03:52 pm, Nivedita Singhvi wrote:
> John Heffner wrote:
> > On Tuesday 17 May 2005 03:25 pm, Nivedita Singhvi wrote:
> >>Yes, a different manifestation of the problem ;). I was talking
> >>in the context of current Linux code and the common ethernet drivers
> >>and typical current Internet/Intranet latencies.
> >
> > The problem is latency independent.
>
> Not entirely - because our reassembly timeout expires, typically.
> (If I understand you right).

Timer expiration is not dependent on latency, nor is IP ID wrap time.

  -John
