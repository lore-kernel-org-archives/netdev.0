From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v5] net: dev_weight: TX/RX orthogonality
Date: Mon, 13 Feb 2017 21:22:00 +0100
Message-ID: <a8c4f11f-a198-ac10-aad8-29b4724512a0@gmx.net>
References: <20161229.144555.1740958763290967121.davem@davemloft.net>
 <1483043841-10016-1-git-send-email-matthias.tafelmeier@gmx.net>
 <20161229.201647.324176080385260025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha384;
 protocol="application/pgp-signature";
 boundary="t3jeaNhoThDnhhVP5uximo70A1ctwXJhW"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:58160 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752891AbdBMUWK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 15:22:10 -0500
In-Reply-To: <20161229.201647.324176080385260025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--t3jeaNhoThDnhhVP5uximo70A1ctwXJhW
Content-Type: multipart/mixed; boundary="BwxsWAiAfAewUbDDTkjFLpXSCBl9ErN7B";
 protected-headers="v1"
From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Message-ID: <a8c4f11f-a198-ac10-aad8-29b4724512a0@gmx.net>
Subject: Re: [PATCH v5] net: dev_weight: TX/RX orthogonality
References: <20161229.144555.1740958763290967121.davem@davemloft.net>
 <1483043841-10016-1-git-send-email-matthias.tafelmeier@gmx.net>
 <20161229.201647.324176080385260025.davem@davemloft.net>
In-Reply-To: <20161229.201647.324176080385260025.davem@davemloft.net>

--BwxsWAiAfAewUbDDTkjFLpXSCBl9ErN7B
Content-Type: multipart/mixed;
 boundary="------------A27FC6E15724014C5B218CEF"

This is a multi-part message in MIME format.
--------------A27FC6E15724014C5B218CEF
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


>> Oftenly, introducing side effects on packet processing on the other ha=
lf
>> of the stack by adjusting one of TX/RX via sysctl is not desirable.
>> There are cases of demand for asymmetric, orthogonal configurability.
>>
>> This holds true especially for nodes where RPS for RFS usage on top is=

>> configured and therefore use the 'old dev_weight'. This is quite a
>> common base configuration setup nowadays, even with NICs of superior p=
rocessing
>> support (e.g. aRFS).
>>
>> A good example use case are nodes acting as noSQL data bases with a
>> large number of tiny requests and rather fewer but large packets as re=
sponses.
>> It's affordable to have large budget and rx dev_weights for the
>> requests. But as a side effect having this large a number on TX
>> processed in one run can overwhelm drivers.
>>
>> This patch therefore introduces an independent configurability via sys=
ctl to
>> userland.
>>
>> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> Much better, applied, thanks.
>

Excuse me, have you rejected that one in the meantime/afterwards?
Checked in Hartman's and Linus tree and your current net. It's not applie=
d.

Thanks!



--------------A27FC6E15724014C5B218CEF
Content-Type: application/pgp-keys;
 name="0x8ADF343B.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x8ADF343B.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQENBFJ0FzIBCADZ/hkwcprVGydMOqeqM+2k6v5e5kb4YDMKU7nMbCVmH4sn01T7
Yh9kDwG5LOMLD06BB2txjLBvTY+c0mpK+hE4pWr+i3qhU5CbVvx7jppJqCD6ZT/T
A3I7NxsdixRvLIF4UXgKQOMKPIx+aw/sp86NqzCLAMse7F0vXUjAP5YANtJid2rf
r/B37BGKhqDGhi4Appz4UZOzpRov/v8JD4XScuvJnl09/oi5cDj3Mn2uqOc/G6hA
t7HXsbHh4dKxd3AftqPPzEkJAmm+9Z4ASG9hy8IXms8Czimr+BGL0CnfsJlX6DCU
m6mVDqT1GJyzmP4zkWcPi+2fOI4KtpV+C7+bABEBAAG0Ok1hdHRoaWFzIFRhZmVs
bWVpZXIgKHByaXZhdCkgPG1hdHRoaWFzLnRhZmVsbWVpZXJAZ214Lm5ldD6JAUEE
EwECACsCGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAhkBBQJWPZvDBQkHi+uR
AAoJEOAWT1uK3zQ78DYH/3Yrxc7v7VtXUJcy83wY24syxN2vljrN3e5hadpaf/6f
9IJqMUlQFTEsDuokL4dsXPCGqJFjS2InH+6WGGBbJ+F0gkfGwjOZ7A09MWuZkpxP
zZW7sky1NOplrOzOcwEAq+sZx5Y9BgJmNaZXRSDkotj6izZibZkACA73J7cMOALF
ULIvV6p/ED1x85fF4EXogc6ZVXv3QhZ5io43UoLS8YfxUvFftw04Gd0wipDIlOQR
LCY4Oj5lr0O8PIwbZYImtSslfxqb/wpAqJSJ+1nml4zn1Cyf6bMCccQbUUfLu9Lm
0fSRX0/b5PyEXqo7WAR3CmtyirM6C+hcVwDQNGucwqKJARwEEwECAAYFAlP4qFwA
CgkQc1YJs62PXiMJwggAgwa8bM1DVdB5wdWVbsEvjDWgoD4CZOH+3/nCAKFv+eKf
d3GrJUtOh3T/QVpmbVgNwnyqqNLGlyIOHltVkrn9WqSC33kuXsIStR6KM+LXnA99
FjyAiTcVbzbfl/XNlIQrgV9+niSSUFCUge5242itPjBBCtlYHUkQ5Y9hsNwV9Hb7
dpVxUf01CJcNKlWscC7lTt2FqjJrIOw2NHxgHWxRlDqo9dFg4uwI+O90orKAyJ6N
Sowu2Ca6DXB3jHgoG7WbAh1nEVus/JkyVsnTIMCsfOpwhJNd1fvy6JMVAe7+/p6/
JGZcMjUTadmsHeJHwqOJSVOoX3Y8CZkV8/PHIqmYvokBPgQTAQIAKAUCU/hT+gIb
AwUJAeEzgAYLCQgHAwIGFQgCCQoLBBYCAwECHgECF4AACgkQ4BZPW4rfNDvHZAf7
BpqfTpLdR25q72DZ4T6SrkcZCOJ8jJQhQ1K9cAc0snpK+jcWg9iUgCpV8QJiXpGL
dAkux/YCu7SRstOSbMv4G4Qb/g8y2bowFI/mAzK1o6s6CYt3URNBe7zRLK6sJbK0
f5fDpWoRufW9/Ppj1/S7dki5JpkUlyGa/y2O+X4C/P0Rh3HfL5HicRHamc7PVElh
z/8nVA+KUkcA9ksVJqe50LahTbDyqOmd8cjSdUKlH2dsP/cAmZfU3IAa26UBKWVn
rxnQ61VV5QLpcYvW3jTfzBy7xv1s7YSj2rFpIC5WKgPC/p+2gqVMSGI1hRlrNaSA
qH9XgWNPCa5NlOxuN4mSN4kBQQQTAQIAKwIbAwYLCQgHAwIGFQgCCQoLBBYCAwEC
HgECF4AFCQSrhqYFAlRXtDwCGQEACgkQ4BZPW4rfNDvqmQf/Wa2LXaOvzftegDI+
LAiFOB/Dq5yhFp6urk5+yC+YzCFin8HfP+LVXR8Xkei6fMmFMjfRU0MrNLBxFd3I
UrIgRrtmJGaHB+vkIqNGgU8LcpHBdd6nprtIF53IhtOINwkmCgLzWi3sGYJ4yQyj
9OSNnh7j7ENFeZd8LgN/FgB5GjPisN3zJD19z065jlfeXvHIZOL90PaTqih90x6n
oTr4dbKhk1t9zZYhY5W812gCMVn2g4wLLO+iijKOe8uNrOw22xDGckoL5UFRE8Vj
Twup3eYyzb/2TVpAmM5GhnI+PodZ6GGcQRVKGMYwYyFVLDEcDRxAUpwfXfUzHwvD
op2fQ7Q/TWF0dGhpYXMgVGFmZWxtZWllciAoSGFwbG9ycmhpbmkpIDxtYXR0aGlh
cy50YWZlbG1laWVyQGdteC5uZXQ+iQEfBDABAgAJBQJWPZtPAh0AAAoJEOAWT1uK
3zQ7FrIH/3OFr/bZ2UQeJrn9n67G9o9neJv4ES9Lcq6xnCIc+ZRHqrBTwsYkfYC5
MEMTF7TMFNUJTr2Np3OG7iKcHVePpeMpHicXppJ4hUsIQ0kwXlynRAScrAqoQHBD
IKzu5qHDME0UKIWr9iTASFHJgZGyH6OoPh7LIifV8cGdVPQ/5FF1kqM4YMZ3IygO
C3CaYtEaOz0B1L00zJan8rbEnpsI1msZ3hjacGB2SD5kFAUMDbpoXVOOE07GSLF0
KKhMv02WdrKO8iedStubO9BON9Vf7IIq21RpDEhhjAzt4Ui2q0UEodTvnBX4ifFM
UEU/+NdC3deuRwdxOq1ozSQlUTzVFASJATQEEwECAB4CGwMCHgECF4ACCwkCFQoC
FgMFAlRXs+UFCQSrhqYACgkQ4BZPW4rfNDs/HQf+K5swcPreRRBXQbTBCgTQAoAI
JtvG+TLlPPnpYMqkQoKIhw/USN2Je4Gqm3DhRcCteA5wbmhlHj9DbapbCOwE7vfK
3YC/hpntvnmgCl6atT2QbE4Ak7xeT2ljLiRYD1re7oE8fAUqkI2S+vePiK1+b8Cc
OKPmuAJYmgAMmNVMKcknryNoFc7xseNEy58T+AoyCKcxV9ZJdyd+6Ye48LkRlmyf
lfRnCvgfS74TEq7Gr5uCJPgqcjrl8SS3G6jgUrzPcV2mFROt9EH3d80T+GOIy4pB
SeYGdfkeqUbflj0CeRIyazzAZurllCQWjpaeh009Y/wuzLm91zrVWwADP/5oRIkB
HAQTAQIABgUCU/ioXAAKCRBzVgmzrY9eI23xB/461lM4c/08tEwmd0oC1jdwyidO
ZRCj/vOqZ+Af6oB3FdpWseuKWdJ7zb8NR+BcEUQRqbaF/677cCrKIEnRoq7IzNsw
KiqK9K5cFHLtm9TNZ0Mf5QP/PG47Jrex5l59LMMz+LW1Rv/uXJjTQDeQYsrYDAPK
mJx2c0OyzZnr+CRrHJKUH0P+oVBvSQEnDTbCT2W9wuLrDIHF6H3YQLAuCS2sslq5
teAinTjTGnPmkP7hKcK3CC0BdiUgFFybIZOGthFm+bTG+V3qGUiam95dqDmQ2VTX
QxCetGDTjUrvKdODh5qLFUM+StWLNEP+QtMcymZfrRIHayKS3GyjKBOPoCZpiQE0
BBMBAgAeAhsDBQkB4TOAAh4BAheABQJSdB8LAgsJAhUKAhYDAAoJEOAWT1uK3zQ7
5nMH/iscBMT7fEnIBeYZlFaxiJmFobRVWFP/A2IfzvKVIdY9vDqjN5M5chrRfsk9
HI0EPbiF3kmVwmRdl8J5fgN7O8QFbhW4ojda8UXBAsgF50kurqk2NrdgM+xLy2TI
jVZdwQYK+R11SpO9xaf+nqLKV8r9VkQ5mzb+BEzDiaX7z9IBrm28v0BfelDZVRzW
cOrskVnwX1PySt3xvCwwo3cwY39yno7H4AlgTXhAvhwI6DQMxZXm4MZcugSfB5b4
2uyslOOxMkgvLW1CmpJxzbWXYT+40vW0DbQAUC1VIr7hiPrunrRAWfbV/RWZl6lr
6gMJJXkLGN70MUX40FF0IhZw5Ja5AQ0EUnQXMgEIAPICr+5yNyuVcmsv5xpmRKnz
KoTjJ7xt0EPiru895LEUPN25tJyi8PZmLciNJnEoQ231jjAloQvx1pb3cr35zzGX
PTPJ5fEECZDxMWMjVvCMb4XK0YjqCF9i/uKic5zqjwRNAPEGTO/ZgS+e21lUJSmu
KR6m5WQcKgBH+tqS3rodgjunnIN4UiNMxbq/VVGICWPjdgoTkqWE3r8QthKLg4Lj
zILEH3HbG39l+vTwEKaP4q5xShFZjRUrZC2anBP+gQx/FbBff3ufpCL9LF5dkywZ
P3NHVyaa/D8T66CTj7Rynd4NZy/qdqGMjMjEuf0RkgXF7Uar4GXmuOfrIcf/X6EA
EQEAAYkBJQQYAQIADwIbDAUCVj2bwwUJB4vrkQAKCRDgFk9bit80O/0ZCACoWtov
fl7vH3YNW0K3xWil9wj43X2OxwKiGBdfbI48bW+b6LJQwNwFePFQ/RQCBgg1eerU
Oys0ymcmp0VeMdwpw27qWcMcbsDn3Pucqp1C2IUuXesbUcRo+QDqhl96KxAAWY5O
JO16dfRrIxyX6Pb0uImqpDetT4Kbr1doTF8cIfRH2rszHKU9BEWag/us9V8H5S8h
F7Ws2wH2JlWbQpP8E7/Z5kVM9psdqX9rwbrUAqpyNhtILoC0+zXkdnOxz1WZaBpr
ckEYQS4/CQOliYJyd5nXYcwVXCNpdy1Vt53ArN9j/EIvfFxOPCPoBQj1b9nkHqNn
qnlCR0LVNOnSE3Eb
=3D0oZJ
-----END PGP PUBLIC KEY BLOCK-----

--------------A27FC6E15724014C5B218CEF--

--BwxsWAiAfAewUbDDTkjFLpXSCBl9ErN7B--

--t3jeaNhoThDnhhVP5uximo70A1ctwXJhW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBCQAGBQJYohVoAAoJEOAWT1uK3zQ7tXgH/2nFGHlUe0l97V2yKzCv34cI
H39jikcvbQOSw2xDr4ADAXHaVr0uLgTcE4HR7oTPPHpO3xmejoCxmTwHYHzqws06
ji4017Ta2pPXMBpBeLLEvp/VZhtFXt3yPmRsIsScF4TnlANAPgoqBNqFncn5eS8W
G4Y3X2IXMyacQrSm1CF7rm/RMD9jOoiBECALYVzonEsbDWMqnze7SVwk16k7cRF3
ne8St9BlJ4Lo9qPhUkpuwGH0Y9DMtahCZwgx2XYv/GSmKwVaHQWw5dXGo91mFjqC
YcxI7op9kRUtKH756E++mHt1H07AjrWR0DXqrhSpbqa0PR4+CqT81xCbHpkRH6I=
=Fozf
-----END PGP SIGNATURE-----

--t3jeaNhoThDnhhVP5uximo70A1ctwXJhW--
