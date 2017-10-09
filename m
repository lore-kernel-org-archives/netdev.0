From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: netlink backwards compatibility in userspace tools
Date: Mon, 9 Oct 2017 13:34:18 +0200
Message-ID: <CAHmME9rEokbPUVgdtWeEQrdd5bbhZiXLa-Q3PBKouD-dV1Drsg@mail.gmail.com>
References: <CAHmME9oixZtPVdH24KJQ9NaTuf_ECAOoHwQhuA+Fy-BX+F_3dw@mail.gmail.com>
 <20171008.214726.1977368725573365543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171008.214726.1977368725573365543.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

That seems wise. Thanks for the advice. A more sophisticated way of
approaching this would be for the kernel to also send a bitmap of
which attributes are "critical" and only warn (or even error) of
_those_ are not understood. But that seems needlessly complex, and so
I think I'll go with your suggestion, and simply warn once with a
shorter message.

Jason
