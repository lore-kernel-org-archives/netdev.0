From: Markos Chandras <markos.chandras@imgtec.com>
Subject: Re: [PATCH] net: ethernet: pcnet32: Setup the SRAM and NOUFLO on
 Am79C97{3,5}
Date: Thu, 19 Mar 2015 08:37:05 +0000
Message-ID: <20150319083704.GA31322@mchandras-linux.le.imgtec.org>
References: <1426709407-16033-1-git-send-email-markos.chandras@imgtec.com>
 <1426730854.1840.23.camel@Lunix2.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: <linux-mips@linux-mips.org>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Don Fry <pcnet32@frontier.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426730854.1840.23.camel@Lunix2.home>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Don,

On Wed, Mar 18, 2015 at 07:07:34PM -0700, Don Fry wrote:
> One little change to the comment is needed.  See below
> 
> Don
> 
> On Wed, 2015-03-18 at 20:10 +0000, Markos Chandras wrote:
> > +	if (sram) {
> > +		/*
> > +		 * The SRAM is being configured in two steps. First we
> > +		 * set the SRAM size in the BCR25:SRAM_SIZE bits. According
> > +		 * to the datasheet, each bit corresponds to a 512-byte
> > +		 * page so we can have at most 24 pages. The SRAM_SIZE
> > +		 * corresponds holds the value of the upper 8 bits of
> > +		 * the 16-bit SRAM size. The low 8-bits start at 0x00
> > +		 * and end at 0xff. So the address range is from 0x0000
> > +		 * up to 0x17ff. Therefore, the SRAM_SIZE is set to 0x17.
> > +		 * The next step is to set the BCR24:SRAM_BND midway through
> > +		 * so the Tx and Rx buffers can share the SRAM equally.
> > +		 */
> 
> The comment specifies BCR24 but the code is changing BCR26 which matches
> the documentation.  Please correct the comment to avoid confusion.
> 

Ah good catch. I will fix it and send a v2.

-- 
markos
