From: Rob Herring <robh@kernel.org>
Subject: Re: [RFC 1/2] dt: emac: document device-tree based phy discovery and
 setup
Date: Wed, 8 Feb 2017 17:00:30 -0600
Message-ID: <20170208230030.3mzhe4e7kj6k6xdh@rob-hp-laptop>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        Mark Rutland <mark.rutland@arm.com>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:35386 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdBHXa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 18:30:29 -0500
Content-Disposition: inline
In-Reply-To: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 05, 2017 at 11:25:05PM +0100, Christian Lamparter wrote:
> This patch adds documentation for a new "phy-handler" property

s/phy-handler/phy-handle/

> and "mdio" sub-node. These allows the enumeration of PHYs which
> are supported by the phy library under drivers/net/phy.
> 
> The EMAC ethernet controller in IBM and AMCC 4xx chips is
> currently stuck with a few privately defined phy
> implementations. It has no support for PHYs which
> are supported by the generic phylib.
> 
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
> ---
>  .../devicetree/bindings/powerpc/4xx/emac.txt       | 60 +++++++++++++++++++++-
>  1 file changed, 58 insertions(+), 2 deletions(-)

Otherwise,

Acked-by: Rob Herring <robh@kernel.org>
