From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3 v10] Add support for rmnet driver
Date: Tue, 29 Aug 2017 18:12:44 -0700 (PDT)
Message-ID: <20170829.181244.658164638453646342.davem@davemloft.net>
References: <1504054078-10173-1-git-send-email-subashab@codeaurora.org>
        <20170829.180557.1826943085634265902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@ACULAB.COM, marcel@holtmann.org, andrew@lunn.ch
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751329AbdH3BMp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 21:12:45 -0400
In-Reply-To: <20170829.180557.1826943085634265902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sigh, I had to revert.

You only allow RMNET to take on the values 'y' and 'n'.

You must allow for it to be 'm' and modular as well.
