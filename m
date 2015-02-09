From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Mon, 9 Feb 2015 13:26:53 +0100
Message-ID: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
References: <1423477027-10869-1-git-send-email-kristian.evensen@gmail.com>
	<87a90nqp45.fsf@nemi.mork.no>
	<CAKfDRXhW-izhes0qq2qJA0ojm37Eg=dybYSdzo8u-VzhT15EGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e0158c79ca4af7d050ea6e258
Cc: Network Development <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:61534 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755910AbbBIM0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 07:26:54 -0500
Received: by mail-yh0-f50.google.com with SMTP id a41so7342924yho.9
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 04:26:53 -0800 (PST)
In-Reply-To: <CAKfDRXhW-izhes0qq2qJA0ojm37Eg=dybYSdzo8u-VzhT15EGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e0158c79ca4af7d050ea6e258
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Feb 9, 2015 at 12:55 PM, Kristian Evensen
<kristian.evensen@gmail.com> wrote:
> Hi,
>
> On Mon, Feb 9, 2015 at 12:51 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>> Just to be sure: You do have a configuration where interfaces #10 and
>> #11 are visible, but none of them respond to any QMI at all?  Not even
>> CTL SYNC?  Could you get a minimal usbmon trace of that?

Here is a minial usbmon where I send SYNC to interface 10. After I
made the trace, I tried interface 8 (to make sure that there was
nothing wrong with modem) and it worked fine. ModemManager or any
similar tool is not running.

The firmware is SWI9X15C_05.05.02.00 r19147 carmd-fwbuild1 2013/11/15 13:54=
:28

-Kristian

--089e0158c79ca4af7d050ea6e258
Content-Type: text/x-log; charset=US-ASCII; name="mc73xx-intf-10-no-reply.log"
Content-Disposition: attachment; filename="mc73xx-intf-10-no-reply.log"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i5xu39ap0

ZmZmZjg4MDBjYmJhZDI0MCAxNDI5NTY5MzA0IFMgSWk6MzowNTA6NyAtMTE1OjI1NiAxMCA8CmZm
ZmY4ODAwY2JiYWRiNDAgMTQyOTU2OTU2NiBTIENvOjM6MDUwOjAgcyAyMSAwMCAwMDAwIDAwMGEg
MDAwYyAxMiA9IDAxMGIwMDAwIDAwMDAwMDAxIDI3MDAwMDAwCmZmZmY4ODAwY2JiYWRiNDAgMTQy
OTU3MDMzNyBDIENvOjM6MDUwOjAgMCAxMiA+CmZmZmY4ODAwY2JiYWQyNDAgMTQzNDU3Njk2NiBD
IElpOjM6MDUwOjcgLTI6MjU2IDAKZmZmZjg4MDBjYmJhZDI0MCAxNDM0NTc3MDYxIFMgSWk6Mzow
NTA6NyAtMTE1OjI1NiAxMCA8CmZmZmY4ODAwY2JiYWRiNDAgMTQzNDU3NzE1NCBTIENvOjM6MDUw
OjAgcyAyMSAwMCAwMDAwIDAwMGEgMDAwYyAxMiA9IDAxMGIwMDAwIDAwMDAwMDAxIDI3MDAwMDAw
CmZmZmY4ODAwY2JiYWRiNDAgMTQzNDU3Nzk2OCBDIENvOjM6MDUwOjAgMCAxMiA+CmZmZmY4ODAw
Y2JiYWQyNDAgMTQzOTU4NDU2NCBDIElpOjM6MDUwOjcgLTI6MjU2IDAKZmZmZjg4MDBjYmJhZDI0
MCAxNDM5NTg0Njg3IFMgSWk6MzowNTA6NyAtMTE1OjI1NiAxMCA8CmZmZmY4ODAwY2JiYWRiNDAg
MTQzOTU4NDgyOSBTIENvOjM6MDUwOjAgcyAyMSAwMCAwMDAwIDAwMGEgMDAwYyAxMiA9IDAxMGIw
MDAwIDAwMDAwMDAxIDI3MDAwMDAwCmZmZmY4ODAwY2JiYWRiNDAgMTQzOTU4NTY5OSBDIENvOjM6
MDUwOjAgMCAxMiA+CmZmZmY4ODAwY2JiYWQyNDAgMTQ0MDQ3NzA1NSBDIElpOjM6MDUwOjcgLTI6
MjU2IDAK
--089e0158c79ca4af7d050ea6e258--
