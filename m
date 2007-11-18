From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Sun, 18 Nov 2007 20:54:11 +0100
Message-ID: <47409863.8000902@trash.net>
References: <47408BBC.6040608@unsolicited.net> <200711182131.38388.ismail@pardus.org.tr> <474093E0.3090007@unsolicited.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020507060706030908040200"
Cc: =?UTF-8?B?SXNtYWlsIETDtm5tZXo=?= <ismail@pardus.org.tr>,
	netdev@vger.kernel.org
To: David <david@unsolicited.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44146 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbXKRTyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 14:54:19 -0500
In-Reply-To: <474093E0.3090007@unsolicited.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020507060706030908040200
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

David wrote:
> Ismail Dönmez wrote:
>   
>> Sunday 18 November 2007 Tarihinde 21:00:12 yazmıştı:
>>   
>>     
>>> I'm (very) far from being firewall configuration expert, but I'm seeing
>>> a consistent kernel panic when the following rule is triggered.
>>>
>>>     iptables -t nat -A PREROUTING -j REDIRECT -i eth2 -p udp --dport
>>> 5061 --to-ports 5060
>>>
>>> (I'm trying to redirect an alternate port to a SIP server)
>>>
>>> Am I just being very stupid, or is there something I'm not seeing here?
>>>     
>>>       
>> Also post the kernel panic log.
>>   
>>     
> This is a bit difficult since the server is headless (normally). I can
> try to obtain the panic via a temporary console, but it may have to wait
> for a day or two.
>   

Please try if this patch fixes the problem.

--------------020507060706030908040200
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

W05FVEZJTFRFUl06IEZpeCBOVUxMIHBvaW50ZXIgZGVyZWZlcmVuY2UgaW4gbmZfbmF0X21v
dmVfc3RvcmFnZSgpCgpSZXBvcnRlZCBieSBDaHVjayBFYmJlcnQgYXM6CgoJaHR0cHM6Ly9i
dWd6aWxsYS5yZWRoYXQuY29tL3Nob3dfYnVnLmNnaT9pZD0yNTk1MDEjYzE0CgpUaGlzIHJv
dXRpbmUgaXMgY2FsbGVkIGVhY2ggdGltZSBoYXNoIHNob3VsZCBiZSByZXBsYWNlZCwgbmZf
Y29ubiBoYXMKZXh0ZW5zaW9uIGxpc3Qgd2hpY2ggY29udGFpbnMgcG9pbnRlcnMgdG8gY29u
bmVjdGlvbiB0cmFja2luZyB1c2VycwoobGlrZSBuYXQsIHdoaWNoIGlzIHJpZ2h0IG5vdyB0
aGUgb25seSBzdWNoIHVzZXIpLCBzbyB3aGVuIHJlcGxhY2UgdGFrZXMKcGxhY2UgaXQgc2hv
dWxkIGNvcHkgb3duIGV4dGVuc2lvbnMuIExvb3AgYWJvdmUgY2hlY2tzIGZvciBvd24KZXh0
ZW5zaW9uLCBidXQgdHJpZXMgdG8gbW92ZSBoaWdlci1sYXllciBvbmUsIHdoaWNoIGNhbiBs
ZWFkIHRvIGFib3ZlCm9vcHMuCgpTaWduZWQtb2ZmLWJ5OiBFdmdlbml5IFBvbHlha292IDxq
b2hucG9sQDJrYS5taXB0LnJ1PgpTaWduZWQtb2ZmLWJ5OiBEYXZpZCBTLiBNaWxsZXIgPGRh
dmVtQGRhdmVtbG9mdC5uZXQ+CgotLS0KY29tbWl0IDc3OTk2NTI1NTdkOTY2ZTQ5NTEyNDc5
ZjRkM2I5MDc5YmJjMDFmZmYKdHJlZSBjMDg5NTA4NGUwNzViZjUzNjk3YTY2ODE2ZTZiZmNi
ZTI4ZDM4NTlkCnBhcmVudCBhNWE5NzI2M2E5ZmQ2YTk0Zjk1NGQ0MWFlMzIzM2VhNjVhOTBi
ZDhhCmF1dGhvciBFdmdlbml5IFBvbHlha292IDxqb2hucG9sQDJrYS5taXB0LnJ1PiBUaHUs
IDE1IE5vdiAyMDA3IDE1OjUyOjMyIC0wODAwCmNvbW1pdHRlciBEYXZpZCBTLiBNaWxsZXIg
PGRhdmVtQGRhdmVtbG9mdC5uZXQ+IFRodSwgMTUgTm92IDIwMDcgMTU6NTI6MzIgLTA4MDAK
CiBuZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19leHRlbmQuYyB8ICAgIDIgKy0KIDEgZmls
ZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdp
dCBhL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX2V4dGVuZC5jIGIvbmV0L25ldGZpbHRl
ci9uZl9jb25udHJhY2tfZXh0ZW5kLmMKaW5kZXggYTFhNjVhMS4uY2Y2YmE2NiAxMDA2NDQK
LS0tIGEvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfZXh0ZW5kLmMKKysrIGIvbmV0L25l
dGZpbHRlci9uZl9jb25udHJhY2tfZXh0ZW5kLmMKQEAgLTEwOSw3ICsxMDksNyBAQCB2b2lk
ICpfX25mX2N0X2V4dF9hZGQoc3RydWN0IG5mX2Nvbm4gKmN0LCBlbnVtIG5mX2N0X2V4dF9p
ZCBpZCwgZ2ZwX3QgZ2ZwKQogCQkJcmN1X3JlYWRfbG9jaygpOwogCQkJdCA9IHJjdV9kZXJl
ZmVyZW5jZShuZl9jdF9leHRfdHlwZXNbaV0pOwogCQkJaWYgKHQgJiYgdC0+bW92ZSkKLQkJ
CQl0LT5tb3ZlKGN0LCBjdC0+ZXh0ICsgY3QtPmV4dC0+b2Zmc2V0W2lkXSk7CisJCQkJdC0+
bW92ZShjdCwgY3QtPmV4dCArIGN0LT5leHQtPm9mZnNldFtpXSk7CiAJCQlyY3VfcmVhZF91
bmxvY2soKTsKIAkJfQogCQlrZnJlZShjdC0+ZXh0KTsK
--------------020507060706030908040200--
