From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] kill acient compat cruft from acenic
Date: Sat, 28 Feb 2004 19:29:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040228182907.GA2930@lst.de>
References: <20040227202510.GA19947@lst.de> <403FAECD.3090203@pobox.com> <20040227205729.GB20398@lst.de> <yq01xofgiu5.fsf@wildopensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>
Content-Disposition: inline
In-Reply-To: <yq01xofgiu5.fsf@wildopensource.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 28, 2004 at 01:27:46PM -0500, Jes Sorensen wrote:
> Yeah I am happy to kill support for < 2.4.18 in the driver. But don't
> add that offset_in_page macro please, it's butt ugly.

I didn't add it - it's that way in 2.6, I just provided a variant for
2.4 (which is indetical to what you open-code in your 2.4 driver)
