From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/3] net: unix: fix use-after-free
Date: Sun, 11 Oct 2015 04:55:57 -0700 (PDT)
Message-ID: <20151011.045557.2164838188213641141.davem@davemloft.net>
References: <cover.1444363559.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: jbaron@akamai.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1444363559.git.jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogSmFzb24gQmFyb24gPGpiYXJvbkBha2FtYWkuY29tPg0KRGF0ZTogRnJpLCAgOSBPY3Qg
MjAxNSAwMDoxNTo1OSAtMDQwMA0KDQo+IFRoZXNlIHBhdGNoZXMgYXJlIGFnYWluc3QgbWFpbmxp
bmUsIEkgY2FuIHJlLWJhc2UgdG8gbmV0LW5leHQsIHBsZWFzZQ0KPiBsZXQgbWUga25vdy4NCj4g
DQo+IFRoZXkgaGF2ZSBiZWVuIHRlc3RlZCBhZ2FpbnN0OiBodHRwczovL2xrbWwub3JnL2xrbWwv
MjAxNS85LzEzLzE5NSwNCj4gd2hpY2ggY2F1c2VzIHRoZSB1c2UtYWZ0ZXItZnJlZSBxdWl0ZSBx
dWlja2x5IGFuZCBoZXJlOg0KPiBodHRwczovL2xrbWwub3JnL2xrbWwvMjAxNS8xMC8yLzY5My4N
Cg0KSSdkIGxpa2UgdG8gdW5kZXJzdGFuZCBob3cgcGF0Y2hlcyB0aGF0IGRvbid0IGV2ZW4gY29t
cGlsZSBjYW4gYmUNCiJ0ZXN0ZWQiPw0KDQpuZXQvdW5peC9hZl91bml4LmM6IEluIGZ1bmN0aW9u
IKF1bml4X2RncmFtX3dyaXRhYmxlojoNCm5ldC91bml4L2FmX3VuaXguYzoyNDgwOjM6IGVycm9y
OiChb3RoZXJfZnVsbKIgdW5kZWNsYXJlZCAoZmlyc3QgdXNlIGluIHRoaXMgZnVuY3Rpb24pDQpu
ZXQvdW5peC9hZl91bml4LmM6MjQ4MDozOiBub3RlOiBlYWNoIHVuZGVjbGFyZWQgaWRlbnRpZmll
ciBpcyByZXBvcnRlZCBvbmx5IG9uY2UgZm9yIGVhY2ggZnVuY3Rpb24gaXQgYXBwZWFycyBpbg0K
DQpDb3VsZCB5b3UgZXhwbGFpbiBob3cgdGhhdCB3b3JrcywgSSdtIGhhdmluZyBhIGhhcmQgdGlt
ZSB1bmRlcnN0YW5kaW5nDQp0aGlzPw0KDQpBbHNvIHBsZWFzZSBhZGRyZXNzIEhhbm5lcydzIGZl
ZWRiYWNrLCB0aGFua3MuDQo=
