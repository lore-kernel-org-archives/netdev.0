From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: don't dereference ptr before leaving
 _sctp_walk_{params,errors}()
Date: Fri, 14 Jul 2017 08:58:32 -0700 (PDT)
Message-ID: <20170714.085832.929093611392872988.davem@davemloft.net>
References: <20170714100329.105604-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        lucien.xin@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714100329.105604-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQWxleGFuZGVyIFBvdGFwZW5rbyA8Z2xpZGVyQGdvb2dsZS5jb20+DQpEYXRlOiBGcmks
IDE0IEp1bCAyMDE3IDEyOjAzOjI5ICswMjAwDQoNCj4gIHYyOiBwZXIgY29tbWVudCBmcm9tIERh
dmlkIE1pbGxlciwgbWFrZSBzdXJlIHRoZSB3aG9sZSBpdGVyYXRvci0+bGVuZ3RoDQo+ICAgICAg
Zml0cyBpbnRvIHRoZSByZW1haW5pbmcgYnVmZmVyLg0KDQpQbGVhc2UgY29tcGlsZSBhbmQgZnVu
Y3Rpb25hbGx5IHRlc3QgeW91ciBjaGFuZ2VzOg0KDQpJbiBmaWxlIGluY2x1ZGVkIGZyb20gLi9p
bmNsdWRlL2xpbnV4L2NvbXBpbGVyLmg6NTg6MCwNCiAgICAgICAgICAgICAgICAgZnJvbSAuL2lu
Y2x1ZGUvdWFwaS9saW51eC9zdGRkZWYuaDoxLA0KICAgICAgICAgICAgICAgICBmcm9tIC4vaW5j
bHVkZS9saW51eC9zdGRkZWYuaDo0LA0KICAgICAgICAgICAgICAgICBmcm9tIC4vaW5jbHVkZS91
YXBpL2xpbnV4L3Bvc2l4X3R5cGVzLmg6NCwNCiAgICAgICAgICAgICAgICAgZnJvbSAuL2luY2x1
ZGUvdWFwaS9saW51eC90eXBlcy5oOjEzLA0KICAgICAgICAgICAgICAgICBmcm9tIC4vaW5jbHVk
ZS9saW51eC90eXBlcy5oOjUsDQogICAgICAgICAgICAgICAgIGZyb20gbmV0L3NjdHAvc21fc3Rh
dGVmdW5zLmM6NDg6DQpuZXQvc2N0cC9zbV9zdGF0ZWZ1bnMuYzogSW4gZnVuY3Rpb24goXNjdHBf
c2ZfZG9fcmVjb25mojoNCi4vaW5jbHVkZS9uZXQvc2N0cC9zY3RwLmg6NDcyOjI0OiBlcnJvcjog
dW5rbm93biB0eXBlIG5hbWUgoXNjdHBfcGFyYW1oZHJfdKINCiAgICAgIChwb3MudiArIG9mZnNl
dG9mKHNjdHBfcGFyYW1oZHJfdCwgbGVuZ3RoKSArIHNpemVvZihwb3MucC0+bGVuZ3RoKSA8XA0K
ICAgICAgICAgICAgICAgICAgICAgICAgXg0K
