From: ayuj <ayuj.verma@gmail.com>
Subject: Configure traffic class to bringup DCB in back-to-back setup
Date: Wed, 13 Jul 2016 09:09:06 +0000 (UTC)
Message-ID: <loom.20160713T110657-740@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52297 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbcGMJJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 05:09:25 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1bNGAK-0006SJ-Vb
	for netdev@vger.kernel.org; Wed, 13 Jul 2016 11:09:13 +0200
Received: from static-67.218.93.111-tataidc.co.in ([static-67.218.93.111-tataidc.co.in])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 11:09:12 +0200
Received: from ayuj.verma by static-67.218.93.111-tataidc.co.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 11:09:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SSBqdXN0IGNoZWNrZWQgVExWJ3MuIEJlbG93IGFyZSB0aGUgZGV0YWlsczoKCk9TIDotIENlbnRPUyA3LjIKa2VybmVsIDMuMTAuMC0zMjcuZWw3Lng4Nl82NApsbGRwYWQ6LSBsbGRwYWQgdjAuOS40NgpkY2J0b29sOi0gdjAuOS40NgppeGdiZSA6LSBpeGdiZS00LjMuMTUKCnN0ZXBzIGZvbGxvd2VkOi0gCgojIG1vZHBvcmJlIGl4Z2JlCiMgc2VydmljZSBsbGRwYWQgc3RhcnQgCiAgICBSZWRpcmVjdGluZyB0byAvYmluL3N5c3RlbWN0bCBzdGFydCAgbGxkcGFkLnNlcnZpY2UKCiMgc2VydmljZSBsbGRwYWQgc3RhdHVzClJlZGlyZWN0aW5nIHRvIC9iaW4vc3lzdGVtY3RsIHN0YXR1cyAgbGxkcGFkLnNlcnZpY2UK4pePIGxsZHBhZC5zZXJ2aWNlIC0gTGluayBMYXllciBEaXNjb3ZlcnkgUHJvdG9jb2wgQWdlbnQgRGFlbW9uLgogICBMb2FkZWQ6IGxvYWRlZCAoL3Vzci9saWIvc3lzdGVtZC9zeXN0ZW0vbGxkcGFkLnNlcnZpY2U7IGRpc2FibGVkOyB2ZW5kb3IKcHJlc2V0OiBkaXNhYmxlZCkKICAgQWN0aXZlOiBhY3RpdmUgKHJ1bm5pbmcpIHNpbmNlIFR1ZSAyMDE2LTA3LTA1IDA1OjQ5OjEyIEVEVDsgMXMgYWdvCiBNYWluIFBJRDogMTMzNzM3IChs
 bGRwYWQpCiAgIENHcm91cDogL3N5c3RlbS5zbGljZS9sbGRwYWQuc2VydmljZQogICAgICAgICAgIOKUlOKUgDEzMzczNyAvdXNyL3NiaW4vbGxkcGFkIC10CgpKdWwgMDUgMDU6NDk6MTIgbG9jYWxob3N0LmxvY2FsZG9tYWluIHN5c3RlbWRbMV06IFN0YXJ0ZWQgTGluayBMYXllcgpEaXNjb3ZlcnkgUHJvdG9jb2wgQWdlbnQgRGFlbW9uLi4KSnVsIDA1IDA1OjQ5OjEyIGxvY2FsaG9zdC5sb2NhbGRvbWFpbiBzeXN0ZW1kWzFdOiBTdGFydGluZyBMaW5rIExheWVyCkRpc2NvdmVyeSBQcm90b2NvbCBBZ2VudCBEYWVtb24uLi4uCgpsbGRwdG9vbCAtdCAtaSBwM3AyIC1uCkNoYXNzaXMgSUQgVExWCglNQUM6IDAwOjFiOjIxOmJiOjJlOmRhClBvcnQgSUQgVExWCglNQUM6IDAwOjFiOjIxOmJiOjJlOmRhClRpbWUgdG8gTGl2ZSBUTFYKCTEyMApJRUVFIDgwMjFRQVogRVRTIENvbmZpZ3VyYXRpb24gVExWCgkgV2lsbGluZzogeWVzCgkgQ0JTOiBub3Qgc3VwcG9ydGVkCgkgTUFYX1RDUzogOAoJIFBSSU9fTUFQOiAwOjAgMTowIDI6MCAzOjAgNDowIDU6MCA2OjAgNzowIAoJIFRDIEJhbmR3aWR0aDogMCUgMCUgMCUgMCUgMCUgMCUgMCUgMCUgCgkgVFNBX0
 1BUDogMDpzdHJpY3QgMTpzdHJpY3QgMjpzdHJpY3QgMzpzdHJpY3QgNDpzdHJpY3QgNTpzdHJpY3QgNjpzdHJpY3QKNzpzdHJpY3QgCklFRUUgODAyMVFBWiBQRkMgVExWCgkgV2lsbGluZzogeWVzCgkgTUFDc2VjIEJ5cGFzcyBDYXBhYmxlOiBubwoJIFBGQyBjYXBhYmxlIHRyYWZmaWMgY2xhc3NlczogOAoJIFBGQyBlbmFibGVkOiBub25lCkVuZCBvZiBMTERQRFUgVExWCgpQbGVhc2UgaGVscCBtZSBpbiBjb25maWd1cmluZyB0cmFmZmljIGNsYXNzZXMuIEkgd2FudCB0byBicmluZ3VwIERDQiBzZXR1cAppbiBhIGJhY2stdG8tYmFjayBzZW5hcmlvLg==
