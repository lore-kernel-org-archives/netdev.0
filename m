From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: [PATCH] kill acient compat cruft from acenic
Date: 28 Feb 2004 13:27:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <yq01xofgiu5.fsf@wildopensource.com>
References: <20040227202510.GA19947@lst.de> <403FAECD.3090203@pobox.com>
	<20040227205729.GB20398@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040227205729.GB20398@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Christoph" == Christoph Hellwig <hch@lst.de> writes:

Christoph> On Fri, Feb 27, 2004 at 03:55:41PM -0500, Jeff Garzik
Christoph> wrote:
>> Christoph Hellwig wrote: >Kills lots of really old cruft and adds a
>> little cruft to actually >make the driver work with recent 2.4
>> again.
>> 
>> 
>> Since kcompat (http://sf.net/projects/gkernel/) lets PCI API
>> drivers work in 2.2, 2.4 and 2.6, I am OK with applying this
>> patch......  assuming there is a second patch coming to convert to
>> pci_driver API.

Christoph> Jes said he doesn't care for 2.2 and early 2.4 anymore
Christoph> which makes life much easier without external compat cruft.

Christoph> As soon as this patch is in Linus' tree I'll send you a
Christoph> followup.

Yeah I am happy to kill support for < 2.4.18 in the driver. But don't
add that offset_in_page macro please, it's butt ugly.

Cheers,
Jes
