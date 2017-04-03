From: Paul Barker <pbarker@toganlabs.com>
Subject: ethtool-4.8.tar.gz checksum change
Date: Mon, 3 Apr 2017 11:25:54 +0100
Message-ID: <20170403112554.777acee7@host0.betafive.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caracal.maple.relay.mailchannels.net ([23.83.214.30]:44170 "EHLO
        caracal.maple.relay.mailchannels.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752071AbdDCKgN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 06:36:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It looks like the checksum of the following file has changed recently:
    https://www.kernel.org/pub/software/network/ethtool/ethtool-4.8.tar.gz

Original checksum from around 23/10/2016:
    md5sum = 28c4a4d85c33f573c49ff6d81ec094fd
    sha256sum = 1bd82ebe3d41de1b7b0d8f4fb18a8e8466fba934c952bc5c5002836ffa8bb606

Current checksum:
    md5sum = 992eab97607c64b7848edfd37f23da22
    sha256sum = c8ea20b8d85898377ec130066008f9241ebcdd95ac85dbcc2d50b32fe2e2f934

Is this change intentional?

I've spotted this when doing an OpenEmbedded build, it's rejecting the
ethtool-4.8.tar.gz file as corrupted since the checksums do not match those
originally recorded.

Thanks,
Paul Barker
