From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC v3 00/22] Landlock LSM: Unprivileged sandboxing
Date: Wed, 14 Sep 2016 14:36:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00FC881@AcuExch.aculab.com>
References: <20160914072415.26021-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        "linux-api@vger.kernel.org" <linux-api@
To: =?utf-8?B?J01pY2thw6tsIFNhbGHDvG4n?= <mic@digikod.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:53442 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762000AbcINOi7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 10:38:59 -0400
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWlja2HDq2wgU2FsYcO8bg0KPiBTZW50OiAxNCBTZXB0ZW1iZXIgMjAxNiAwODoyNA0K
Li4uDQo+ICMjIFdoeSBkb2VzIHNlY2NvbXAtZmlsdGVyIGlzIG5vdCBlbm91Z2g/DQo+IA0KPiBB
IHNlY2NvbXAgZmlsdGVyIGNhbiBhY2Nlc3MgdG8gcmF3IHN5c2NhbGwgYXJndW1lbnRzIHdoaWNo
IG1lYW5zIHRoYXQgaXQgaXMgbm90DQo+IHBvc3NpYmxlIHRvIGZpbHRlciBhY2NvcmRpbmcgdG8g
cG9pbnRlZCBkYXRhIGFzIGEgZmlsZSBwYXRoLiBBcyBkZW1vbnN0cmF0ZWQNCj4gdGhlIGZpcnN0
IHZlcnNpb24gb2YgdGhpcyBwYXRjaCBzZXJpZXMsIGZpbHRlcmluZyBhdCB0aGUgc3lzY2FsbCBs
ZXZlbCBpcw0KPiBjb21wbGljYXRlZCAoZS5nLiBuZWVkIHRvIHRha2UgY2FyZSBvZiByYWNlIGNv
bmRpdGlvbnMpLiBUaGlzIGlzIG1haW5seSBiZWNhdXNlDQo+IHRoZSBhY2Nlc3MgY29udHJvbCBj
aGVja3BvaW50cyBvZiB0aGUga2VybmVsIGFyZSBub3QgYXQgdGhpcyBoaWdoLWxldmVsIGJ1dA0K
PiBtb3JlIHVuZGVybmVhdGgsIGF0IExTTSBob29rcyBsZXZlbC4gVGhlIExTTSBob29rcyBhcmUg
ZGVzaWduZWQgdG8gaGFuZGxlIHRoaXMNCj4ga2luZCBvZiBjaGVja3MuIFRoaXMgc2VyaWVzIHVz
ZSB0aGlzIGFwcHJvYWNoIHRvIGxldmVyYWdlIHRoZSBhYmlsaXR5IG9mDQo+IHVucHJpdmlsZWdl
ZCB1c2VycyB0byBsaW1pdCB0aGVtc2VsdmVzLg0KDQpZb3UgY2Fubm90IHZhbGlkYXRlIGZpbGUg
cGF0aCBwYXJhbWV0ZXJzIGR1cmluZyBzeXNjYWxsIGVudHJ5Lg0KSXQgY2FuIG9ubHkgYmUgZG9u
ZSBhZnRlciB0aGUgdXNlciBidWZmZXIgaGFzIGJlZW4gcmVhZCBpbnRvIGtlcm5lbCBtZW1vcnku
DQooaWUgeW91IG11c3Qgb25seSBhY2Nlc3MgdGhlIGJ1ZmZlciBvbmNlLikNCg0KVGhpcyBoYXMg
bm90aGluZyB0byBkbyB3aXRoIHdoZXJlIHRoZSBrZXJuZWwgZG9lcyBhbnkgYWNjZXNzIGNoZWNr
cywNCmFuZCBldmVyeXRoaW5nIHRvIGRvIHdpdGggdGhlIGZhY3QgdGhhdCBhbm90aGVyIHRocmVh
ZC9wcm9jZXNzIGNhbg0KbW9kaWZ5IHRoZSBidWZmZXIgYWZ0ZXIgeW91IGhhdmUgdmFsaWRhdGVk
IGl0Lg0KDQoJRGF2aWQNCg0K
