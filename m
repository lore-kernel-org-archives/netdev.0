From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Thu, 22 Jun 2017 10:14:31 +0200
Message-ID: <87o9tg1lso.fsf@miraculix.mork.no>
References: <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com>
        <20170621.173655.1945994342723484710.davem@davemloft.net>
        <CALRmy5tn6cgWF5LP5i7w+UTwP1UJCyQoC7Mx7=RvETBUVD-yuw@mail.gmail.com>
        <20170621.175651.854625612625047729.davem@davemloft.net>
        <125b4ae9-2cb7-3532-5391-24404cf6eaec@gmail.com>
        <24691.1498084768@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Michael J Dilmore <michael.j.dilmore@gmail.com>,
        David Miller <davem@davemloft.net>, vfalico@gmail.com,
        andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <24691.1498084768@famine> (Jay Vosburgh's message of "Wed, 21 Jun
        2017 15:39:28 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh <jay.vosburgh@canonical.com> writes:
> Michael J Dilmore <michael.j.dilmore@gmail.com> wrote:
>
>>if (WARN_ON(!new_active_slave) {
>>    netdev_dbg("Can't add new active slave - pointer null");
>>    return ERROR_CODE
>>}
>
> 	In general, yes, but in this case, the condition should be
> impossible to hit, so BUG_ON seems appropriate.

If it really is impossible then you should simply remove the test. No
need to test for the impossible, is there?


Bj=C3=B8rn
