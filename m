From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ipv4: initialize fib_trie prior to
 register_netdev_notifier call.
Date: Thu, 20 Jul 2017 15:25:17 -0700 (PDT)
Message-ID: <20170720.152517.717593108697149907.davem@davemloft.net>
References: <20170719224133.34666-1-mahesh@bandewar.net>
        <20170719.225136.647816601138954194.davem@davemloft.net>
        <CAF2d9jjWUAffQ9MEc4E1uYTFR1=6EzhABffbTYSDdBwtimsVZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: mahesh@bandewar.net, ebiederm@xmission.com, edumazet@google.com,
        netdev@vger.kernel.org
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934851AbdGTWZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:25:17 -0400
In-Reply-To: <CAF2d9jjWUAffQ9MEc4E1uYTFR1=6EzhABffbTYSDdBwtimsVZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSw
KSA8bWFoZXNoYkBnb29nbGUuY29tPg0KRGF0ZTogVGh1LCAyMCBKdWwgMjAxNyAxMDoyMDowNiAt
MDcwMA0KDQo+IE9uIFdlZCwgSnVsIDE5LCAyMDE3IGF0IDEwOjUxIFBNLCBEYXZpZCBNaWxsZXIg
PGRhdmVtQGRhdmVtbG9mdC5uZXQ+IHdyb3RlOg0KPj4NCj4+IFdoZXJlIGFyZSBwYXRjaGVzICMy
IGFuZCAjMz8NCj4gT29wcywgbXkgYmFkISBJIHdhbnRlZCB0byBkZXRhY2ggdGhpcyBmcm9tIHRo
ZSBzZXJpZXMgYW5kIHNlbmQgaXQNCj4gaW5kZXBlbmRlbnRseSBidXQgZm9yZ290IHRvIHVwZGF0
ZSB0aGUgaGVhZGVyIGluIHByb2Nlc3MuIERvIHlvdSB3YW50DQo+IG1lIHRvIHNlbmQgaXQgYWdh
aW4gd2l0aCBqdXN0IHRoZSBoZWFkZXIgY2hhbmdlIFtQQVRDSCAxLzNdIHRvIFtQQVRDSA0KPiBu
ZXh0XT8NCg0KTm8sIHRoYXQncyBub3QgbmVjZXNzYXJ5Lg0K
