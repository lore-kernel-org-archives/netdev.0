From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: [PATCH] kill acient compat cruft from acenic
Date: 29 Feb 2004 14:10:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <yq0u119g0rh.fsf@wildopensource.com>
References: <20040227202510.GA19947@lst.de> <403FAECD.3090203@pobox.com>
	<20040227205729.GB20398@lst.de> <yq01xofgiu5.fsf@wildopensource.com>
	<20040228182907.GA2930@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040228182907.GA2930@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Christoph" == Christoph Hellwig <hch@lst.de> writes:

Christoph> On Sat, Feb 28, 2004 at 01:27:46PM -0500, Jes Sorensen
Christoph> wrote:
>> Yeah I am happy to kill support for < 2.4.18 in the driver. But
>> don't add that offset_in_page macro please, it's butt ugly.

Christoph> I didn't add it - it's that way in 2.6, I just provided a
Christoph> variant for 2.4 (which is indetical to what you open-code
Christoph> in your 2.4 driver)

Grmbl,

Gains us nothing and is butt ugly, but well ;-( Not going to blame you
for that then, though I'd prefer a patch pulling out the macro use so
one can see what the code does instead.

Anyway, bigger fish to fry.

Jes
