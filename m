From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward
 error correction modes
Date: Tue, 27 Jun 2017 03:22:39 -0700
Message-ID: <20170627032239.05cdc462@cakuba.netronome.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com,
        netdev@vger.kernel.org, vidya.chowdary@gmail.com,
        dustin@cumulusnetworks.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:31499 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751922AbdF0KWt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 06:22:49 -0400
In-Reply-To: <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 Jun 2017 12:19:43 -0700, Roopa Prabhu wrote:
> Encoding: Types of encoding
> Off    :  Turning off any encoding
> RS     :  enforcing RS-FEC encoding on supported speeds
> BaseR  :  enforcing Base R encoding on supported speeds
> Auto   :  IEEE defaults for the speed/medium combination

Just to be sure - does auto mean autonegotiate as defined by IEEE or
some presets?  IIUC there is a notion of different length cables
defaulting to different strength of FEC in 25GE?

Thank you for doing this work!
