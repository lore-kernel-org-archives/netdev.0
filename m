From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Subject: Re: Is ndo_do_ioctl still acceptable?
Date: Thu, 12 Nov 2015 15:30:31 -0500
Message-ID: <5644F6E7.4060901@gmail.com>
References: <CAHmME9puHv8uaUKX4AOjEaTNN6bHqNKqvaCqubc5erk+jnDOEw@mail.gmail.com>
 <20151112083443.48785696@xeon-e3>
 <CAHmME9p31NYxhUeiK=S-6XmKxEBigUyiqEz3SJJrA1zNXaaXLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms090301060805050701000401"
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9p31NYxhUeiK=S-6XmKxEBigUyiqEz3SJJrA1zNXaaXLA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms090301060805050701000401
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-11-12 11:58, Jason A. Donenfeld wrote:
> Hi Stephen,
>
> Thanks for your response.
>
> On Thu, Nov 12, 2015 at 5:34 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> The problem is ioctl's are device specific, and therefore create depen=
dency
>> on the unique features supported by your device.
>> The question always comes up, why is this new API not something genera=
l?
>
> In this case, it really is for unique features of my device. My device
> has its own unique notion of a "peer" based on a particular elliptic
> curve point and some other interesting things. It's not something
> generalizable to other devices. The thing that makes my particular
> device special is these attributes that I need to make configurable. I
> think then, by your criteria, ioctl would actually be perfect. In
> other words, I interpret what you wrote to mean "generalizable:
> netlink. device-specific: ioctl." If that's a decent summary, then
> ioctl is certainly good for me.
>
On the other hand, based on what you are saying about your device, it=20
sounds like you are working on some kind of cryptographically secured=20
(either authenticated or encrypted or both) tunnel, in which case the=20
fact that security is easier to handle with netlink than ioctls becomes=20
important.  If you can't ensure security of the endpoint configuration,=20
you can't ensure security of the tunnel itself.



--------------ms090301060805050701000401
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMTEyMjAzMDMxWjBPBgkq
hkiG9w0BCQQxQgRAt9NGKRSbn6vIURPevdZx8viB6v0se4JtAn6EmVL8S3abgzYB7YT3B8Vo
CTZM/2EkCrotYusgHhme2A8RT448nDBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgAgf9opJ+9DYDUOmFZ8kqK2eQDnwTeUVL8ntCQLzBdcRwGh9E5Z
/b6ZQa+N8rZimDnQck1gBmpMXNSrctFNHkPig7XXvwCSsd37E6N8417hKKGclqKxnX73LAqn
5ZJqPHVn+zw6czVGzLpnpPZWgAu2dI5twZf/xznJR1XSnIxR8/WPqx3+SNFkrSeXzWocIeuq
jQZ1fTbHs8aXc6yrgmucOYHy3bpx4H6jOUonxXDZOUTTToj/OhGVE6Hqyn75YKEXm2W1nIXB
tt3aUknYRUIrczlYEsl5oNQZn54zHyj2k0zyn7cD2WL+rcz4+szAGEI1IpEfWrkcqfzAAcao
4g1KULdcvD1CgUoVusMQf8OO+QkXZHqCEKG8/plkl5e81n1xwIU5VArcaoEg0czKQbIWi0iX
GgtuuG6xvBBGKJdn8iKvuyZtmIYE/6tOtqL799OPyk9QpR5S5YM8zkSTkTNSvE7PuQw3Xz/l
79Few+LBerjA3kfMQa6BqP+1wlDIinAZutRDyCVa6up+mrWkr8Lot8OwIFK8NL/8v4ACHp52
wTg0E2Nymr0TDn5imONeXNAZs9J4ujsNvDD/X49Nd67TOZHKhosM8iW+ccV0b+B2inN1DPoe
r5+orkkjK8xJUTFLaV1mn7p1eyOVz6zFhcYf2Z1NB2ZQ8zurbrHR346K7QAAAAAAAA==
--------------ms090301060805050701000401--
