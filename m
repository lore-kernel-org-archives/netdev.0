From: Zilvinas Valinskas <zilvinas@gemtek.lt>
Subject: Re: Crypto tests via tcrypt.o modules failes
Date: Tue, 28 Sep 2004 12:37:09 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096364229.5548.6.camel@swoop.gemtek.lt>
References: <Xine.LNX.4.44.0409171209190.8510-100000@thoron.boston.redhat.com>
Reply-To: zilvinas@gemtek.lt
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0409171209190.8510-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, 

apparently IPsec and crypto algorithms are ok on IXP 425 (big endian)
system. Not sure what exactly went wrong - I've rm -rf / whole tree , 
applied patches and result - it works .. (I could suspect dependencies
somehow had been broken and not all files were compiled - as a result
miscompilation ? ...)

Anyway, linux 2.4.27 + ipsec (from Herbert) + IXP 425 bits (from
ucLinux) seems is working fine (all crypto modules, not sure only about
cast5 and cast6 algos - as I am not using them here ...)

Zilvinas Valinskas
  

On Fri, 2004-09-17 at 12:09 -0400, James Morris wrote:
> On Fri, 17 Sep 2004, Zilvinas Valinskas wrote:
> 
> > > I've had a report that all is well on an Xscale PXA (SoC) system, with a 
> > > 2.6.7-rc2 kernel.  Are there any significant differences between that and 
> > > what you have?
> > 2.4.27 and 2.6.7-rc2 I think quite different - can you tell me which
> > parts to check for differencies ?
> 
> It should work on either kernel (btw, the PXA is little endian, so they 
> are different).
> 
