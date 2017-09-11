From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net] mlxsw: spectrum: Fix EEPROM access in case of
 SFP/SFP+
Date: Mon, 11 Sep 2017 15:58:26 +0200
Message-ID: <20170911135826.GB27599@lunn.ch>
References: <20170911074226.2020-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, flokli@flokli.de, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37177 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750903AbdIKN6a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 09:58:30 -0400
Content-Disposition: inline
In-Reply-To: <20170911074226.2020-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 11, 2017 at 09:42:26AM +0200, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> The current code does not handle correctly the access to the upper page
> in case of SFP/SFP+ EEPROM. In that case the offset should be local
> and the I2C address should be changed.

Shame you cannot/didn't expose the i2c bus as a linux i2c bus. The AT24 code
does not have this bug!

     Andrew
