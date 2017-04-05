From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ethtool-4.8.tar.gz checksum change
Date: Wed, 5 Apr 2017 10:00:04 -0400
Message-ID: <20170405140003.GB18361@tuxdriver.com>
References: <20170403112554.777acee7@host0.betafive.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Paul Barker <pbarker@toganlabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37141 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755281AbdDEOAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 10:00:18 -0400
Content-Disposition: inline
In-Reply-To: <20170403112554.777acee7@host0.betafive.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 03, 2017 at 11:25:54AM +0100, Paul Barker wrote:
> Hi,
> 
> It looks like the checksum of the following file has changed recently:
>     https://www.kernel.org/pub/software/network/ethtool/ethtool-4.8.tar.gz
> 
> Original checksum from around 23/10/2016:
>     md5sum = 28c4a4d85c33f573c49ff6d81ec094fd
>     sha256sum = 1bd82ebe3d41de1b7b0d8f4fb18a8e8466fba934c952bc5c5002836ffa8bb606
> 
> Current checksum:
>     md5sum = 992eab97607c64b7848edfd37f23da22
>     sha256sum = c8ea20b8d85898377ec130066008f9241ebcdd95ac85dbcc2d50b32fe2e2f934
> 
> Is this change intentional?
> 
> I've spotted this when doing an OpenEmbedded build, it's rejecting the
> ethtool-4.8.tar.gz file as corrupted since the checksums do not match those
> originally recorded.
> 
> Thanks,
> Paul Barker

Yes, the .tar.gz file got regenerated locally as I was tinkering with
the release scripts that I inherited from the former ethtool maintainer,
and the regenerated .tar.gz file got uploaded. The newly updated one
is properly signed and the signature is there to verify. (Note that
the signature is against the .tar file and not the .tar.gz file.)

I downloaded the file from the website and verified against the
matching version of the git tree locally as well. If you have any idea
as to who is in charge of the OpenEmbedded build and can correct/remove
this complaint, then please let me know and/or have them contact me.
(Ditto for Yocto builds...)

Thanks,

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
