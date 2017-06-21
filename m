From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 17:36:55 -0400 (EDT)
Message-ID: <20170621.173655.1945994342723484710.davem@davemloft.net>
References: <1498068137-3550-1-git-send-email-michael.j.dilmore@gmail.com>
        <21644.1498070000@famine>
        <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jay.vosburgh@canonical.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        joe@perches.com
To: michael.j.dilmore@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael D <michael.j.dilmore@gmail.com>
Date: Wed, 21 Jun 2017 22:35:56 +0100

> How do we actually stop a null pointer being dereferenced here?

Maybe that's why it's a BUG_ON(), there is no reasonable way
to continue if the pointer is NULL.
