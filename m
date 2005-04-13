From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Fw: throttling kernel messages: KERNEL: assertion (flags &MSG_PEEK) failed at net/ipv4/tcp.c (1282)
Date: Wed, 13 Apr 2005 09:06:42 -0700
Message-ID: <C925F8B43D79CC49ACD0601FB68FF50C039F358B@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "KOVACS Krisztian" <hidden@balabit.hu>, "Olaf Kirch" <okir@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
>Behalf Of KOVACS Krisztian
>2005-04-12, k keltez=E9ssel 22.39-kor Olaf Kirch ezt =EDrta:
>> >   I also hit these assertions today. In my case it was probably beca=
use
>> > of a slab corruption problem caused by the e100 driver. (I had
>> > CONFIG_DEBUG_SLAB enabled, so a lot of slab corruption messages
>appeared
>> > right before these assertion errors.)
>>
>> Yes, we've seen these symptoms in various bug reports in various 2.6
>> versions, and after some debugging narrowed it down to an e100 driver
>> issue. It went away with 2.6.11 final.
>
>  For me it definitely did not go away with 2.6.11. However, as soo as I
>applied e100-napi-fixes.patch the problem magically disappeared. So I
>suspect this NAPI state machine problem might have been the culprit.
>

This was the exact failure mode of this e100 bug.  It would exhibit with =
slab corruption, only when in NAPI mode.  Glad it fixed your issue as wel=
l.

Jesse
