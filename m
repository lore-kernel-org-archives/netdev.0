From: Xin Long <lucien.xin@gmail.com>
Subject: rhashtable: how to deal with that rhashtable_lookup_insert_key return -EBUSY
Date: Fri, 20 Nov 2015 13:14:18 +0800
Message-ID: <CADvbK_drKzCbByS38==rkC8yRtQhRj6mOtKAgXeHLwOhdh6Z1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: tgraf@suug.ch, herbert@gondor.apana.org.au,
	davem <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, network dev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

when I use rhashtable_lookup_insert_key, sometimes it will return -EBUSY.
im not sure if there is a good way to workabout it.
or I should just try again and again until it's inserted successfully ?

I have seen some use in kernel  by now, but it seems that no one consider
this issue for their cases. but it indeed exists in my case.

did I use it incorrectly or something else ?

Thanks.
