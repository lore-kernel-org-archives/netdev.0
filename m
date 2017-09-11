From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] mlxsw: spectrum: Fix EEPROM access in case of
 SFP/SFP+
Date: Mon, 11 Sep 2017 19:27:53 +0200
Message-ID: <20170911172753.GB1935@nanopsycho>
References: <20170911074226.2020-1-jiri@resnulli.us>
 <20170911135826.GB27599@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, flokli@flokli.de, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33377 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752086AbdIKR15 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 13:27:57 -0400
Received: by mail-wr0-f193.google.com with SMTP id b9so4745509wra.0
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 10:27:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170911135826.GB27599@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 11, 2017 at 03:58:26PM CEST, andrew@lunn.ch wrote:
>On Mon, Sep 11, 2017 at 09:42:26AM +0200, Jiri Pirko wrote:
>> From: Arkadi Sharshevsky <arkadis@mellanox.com>
>> 
>> The current code does not handle correctly the access to the upper page
>> in case of SFP/SFP+ EEPROM. In that case the offset should be local
>> and the I2C address should be changed.
>
>Shame you cannot/didn't expose the i2c bus as a linux i2c bus. The AT24 code

We cannot.
