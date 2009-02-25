From: Denis Romanenko <ash@sevsky.net>
Subject: Kernel problem
Date: Wed, 25 Feb 2009 13:43:32 +0200
Message-ID: <1BAC364C-FDC7-4DD6-A54C-BD6B1DDA4D74@sevsky.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: multipart/signed; boundary=Apple-Mail-11--443025249; micalg=sha1; protocol="application/pkcs7-signature"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sevsky.net ([193.138.84.248]:45526 "EHLO mail.sevsky.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012AbZBYLnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 06:43:43 -0500
Received: from [172.27.136.145] (office.supersky.ua [10.10.10.1])
	by mail.sevsky.net (Postfix) with ESMTP id 847427898E
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 13:43:32 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-11--443025249
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

Hi
I have high loaded router - about 1.2 Gbps

after reboot on new kernel - 2.6.27.17 i have messages in dmesg

WARNING: at kernel/softirq.c:136 local_bh_enable+0x36/0xab()
Modules linked in: netconsole configfs cls_route cls_u32 cls_fw  
sch_sfq sch_htb 8021q i2c_i801 i2c_core rng_core iTCO_wdt  
iTCO_vendor_support e1000e thermal i5000_edac
Pid: 17567, comm: ethtool Not tainted 2.6.27.17 #1
  [<c011d7d5>] warn_on_slowpath+0x41/0x65
  [<c0277fd9>] ? tc_classify_compat+0x2f/0x5e
  [<f88af738>] ? htb_add_to_id_tree+0x6c/0x74 [sch_htb]
  [<f88af7e7>] ? htb_activate_prios+0xa7/0xb2 [sch_htb]
  [<c026cc96>] ? dev_queue_xmit+0x356/0x490
  [<f88b11da>] ? htb_enqueue+0x152/0x1b1 [sch_htb]
  [<c026cd98>] ? dev_queue_xmit+0x458/0x490
  [<c01219d3>] local_bh_enable+0x36/0xab
  [<c026cd98>] dev_queue_xmit+0x458/0x490
  [<c0288334>] ip_finish_output+0x1d0/0x208
  [<c0288610>] ip_output+0x81/0x86
  [<c0285e4b>] ip_forward_finish+0x2f/0x32
  [<c0286042>] ip_forward+0x1f4/0x25a
  [<c0284e17>] ip_rcv_finish+0x2bb/0x2e9
  [<c01324dc>] ? getnstimeofday+0x4f/0xda
  [<c0285271>] ip_rcv+0x1f2/0x21c
  [<c026a3de>] netif_receive_skb+0x3d0/0x424
  [<c02b205e>] __vlan_hwaccel_rx+0x89/0xa7
  [<f886529e>] e1000_receive_skb+0x41/0x61 [e1000e]
  [<f88675c9>] e1000_clean_rx_irq+0x213/0x2a1 [e1000e]
  [<f8864af4>] e1000_clean+0x2ac/0x43a [e1000e]
  [<c027510e>] netpoll_poll+0x77/0x33b
  [<c0275487>] ? netpoll_send_skb+0xb5/0x14f
  [<c0275495>] netpoll_send_skb+0xc3/0x14f
  [<c0275987>] netpoll_send_udp+0x1e8/0x1f0
  [<f88740be>] write_msg+0x6e/0xa1 [netconsole]
  [<f8874050>] ? write_msg+0x0/0xa1 [netconsole]
  [<c011d8c3>] __call_console_drivers+0x56/0x63
  [<c011d927>] _call_console_drivers+0x57/0x5b
  [<c011dca5>] release_console_sem+0x116/0x1ab
  [<c011e20c>] vprintk+0x325/0x352
  [<c0173015>] ? __d_lookup+0xce/0x114
  [<c017303d>] ? __d_lookup+0xf6/0x114
  [<c011e24e>] printk+0x15/0x17
  [<f886226a>] e1000_set_tso+0x4c/0x5d [e1000e]
  [<c026dac7>] dev_ethtool+0x93d/0xd52
  [<c013852a>] ? __lock_acquire+0x606/0x65c
  [<c0136e13>] ? mark_held_locks+0x47/0x62
  [<c0136fba>] ? trace_hardirqs_on+0xb/0xd
  [<c0136f8e>] ? trace_hardirqs_on_caller+0xe1/0x102
  [<c02b8b16>] ? mutex_lock_nested+0x203/0x20b
  [<c0272b62>] ? rtnl_lock+0xf/0x11
  [<c026bc5b>] dev_ioctl+0x460/0x587
  [<c014fd3d>] ? __do_fault+0x2b1/0x2e9
  [<c026056f>] sock_ioctl+0x1c4/0x1d0
  [<c02603ab>] ? sock_ioctl+0x0/0x1d0
  [<c016e382>] vfs_ioctl+0x22/0x67
  [<c016e5fe>] do_vfs_ioctl+0x237/0x245
  [<c01d2cd8>] ? trace_hardirqs_on_thunk+0xc/0x10
  [<c016e638>] sys_ioctl+0x2c/0x48
  [<c01037dd>] sysenter_do_call+0x12/0x35
  =======================
---[ end trace ac68705e6d55d8fc ]---


What the problem on this ?

With best regards Denis Romanenko


--Apple-Mail-11--443025249
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIFJDCCBSAw
ggQIoAMCAQICCgqttb4AAgAM0PYwDQYJKoZIhvcNAQEFBQAwbzEaMBgGA1UEChMRV2ViTW9uZXkg
VHJhbnNmZXIxJjAkBgNVBAsTHVdlYk1vbmV5IENlcnRpZmljYXRpb24gQ2VudGVyMSkwJwYDVQQD
EyBXZWJNb25leSBUcmFuc2ZlciBSb290IEF1dGhvcml0eTAeFw0wODA3MTMxOTA0MDFaFw0wOTA3
MTMxOTE0MDFaMIGBMR0wGwYJKoZIhvcNAQkBFg5hc2hAc2V2c2t5Lm5ldDEaMBgGA1UEChMRV2Vi
TW9uZXkgVHJhbnNmZXIxJjAkBgNVBAsTHVdlYk1vbmV5IENlcnRpZmljYXRpb24gQ2VudGVyMRww
GgYDVQQDExNXTSBpZDogMTA0MzE1MDIwMjQ4MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEAufAv5XtWB9OCZo0iHsfDnQF2zjqceI0b8d9xrnLlTJ2SGshNgYEE8sGbdJZGeX3eclKvBrTD
sWTS1EvJNlZAHUeQv0piteRrR9cHCGXtn55yt5iNsozD6UiAmUQP5gkgtyxBHCmj0NiEGl7DKa9M
MCeyn0kJdW4yOGLOEmGh+WjhQf1QBuTNxVdJLTkYRRp2mEgqbJYJE7l/ImzSmAQBW34SqJpecJsw
xmts9AgRZmg1g9Db6SFYKr+2GYldoRGVzBS8tzw33aapr+Hbv0E34okTKuwT6Ji5HBFKZJio82Mp
2hQdffJ/6NKWyUlp/Fms37trCR8iP5LDLLVvc/hiJQIDAQABo4IBqTCCAaUwHQYDVR0OBBYEFA8Y
oDdt1XjIWWBpMM0Oo4gP7/GfMIGoBgNVHSMEgaAwgZ2AFMudflF+CCDE9XCUoc5SxwVNPzPzoXOk
cTBvMRowGAYDVQQKExFXZWJNb25leSBUcmFuc2ZlcjEmMCQGA1UECxMdV2ViTW9uZXkgQ2VydGlm
aWNhdGlvbiBDZW50ZXIxKTAnBgNVBAMTIFdlYk1vbmV5IFRyYW5zZmVyIFJvb3QgQXV0aG9yaXR5
ghA0dTpSwINwskPtDD7TKrJGMFwGA1UdHwRVMFMwUaBPoE2GS2h0dHA6Ly93d3cud21jZXJ0LmNv
bS9DZXJ0RW5yb2xsL1dlYk1vbmV5JTIwVHJhbnNmZXIlMjBSb290JTIwQXV0aG9yaXR5LmNybDB7
BggrBgEFBQcBAQRvMG0wawYIKwYBBQUHMAKGX2h0dHA6Ly93d3cud21jZXJ0LmNvbS9DZXJ0RW5y
b2xsL2NlcnQud2VibW9uZXkucnVfV2ViTW9uZXklMjBUcmFuc2ZlciUyMFJvb3QlMjBBdXRob3Jp
dHkoMikuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQACg2Cpjiz0xIBoULMPHtbPC5VJBU0NvDKqjkxa
bajsGAAEuofGtTrOT3MUxF8j1bYeXWeHoUNA1z1U0bN2f0gKmQHOLxfEiwOHMp0WHoc0hQjiXJX/
jCngzEDBVfggejOBT5Qp09HxwuwAXMb/ogyd1ssPd++Lh//zumJqDNVpzC84fFtd+x0jsz+Z8RWJ
hF7vzd/sTjJl4mNUYbIx1TUINY8559AeO31LhN8s2IMMErUx8olPbPxjicBkSleE/8dq72nrNmWh
wNNIVokF5KbP/xW8p3XVN2Z7nhuvlrx+LRZiiw3p7/297DZgeLV2dwu3NCzAmhWuqyV5/XqOuTKn
MYIDJTCCAyECAQEwfTBvMRowGAYDVQQKExFXZWJNb25leSBUcmFuc2ZlcjEmMCQGA1UECxMdV2Vi
TW9uZXkgQ2VydGlmaWNhdGlvbiBDZW50ZXIxKTAnBgNVBAMTIFdlYk1vbmV5IFRyYW5zZmVyIFJv
b3QgQXV0aG9yaXR5AgoKrbW+AAIADND2MAkGBSsOAwIaBQCgggF9MBgGCSqGSIb3DQEJAzELBgkq
hkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA5MDIyNTExNDMzMlowIwYJKoZIhvcNAQkEMRYEFMlk
6qdmJSJPCSFmWdIBpGiXRaJRMIGMBgkrBgEEAYI3EAQxfzB9MG8xGjAYBgNVBAoTEVdlYk1vbmV5
IFRyYW5zZmVyMSYwJAYDVQQLEx1XZWJNb25leSBDZXJ0aWZpY2F0aW9uIENlbnRlcjEpMCcGA1UE
AxMgV2ViTW9uZXkgVHJhbnNmZXIgUm9vdCBBdXRob3JpdHkCCgqttb4AAgAM0PYwgY4GCyqGSIb3
DQEJEAILMX+gfTBvMRowGAYDVQQKExFXZWJNb25leSBUcmFuc2ZlcjEmMCQGA1UECxMdV2ViTW9u
ZXkgQ2VydGlmaWNhdGlvbiBDZW50ZXIxKTAnBgNVBAMTIFdlYk1vbmV5IFRyYW5zZmVyIFJvb3Qg
QXV0aG9yaXR5AgoKrbW+AAIADND2MA0GCSqGSIb3DQEBAQUABIIBAEOk3PU7bKgZ6ACqLhubVssb
c1Gb/5z+ZIuhttuEZSewJ3Vf64YKqjP6sRzX8Uv4BHEaksh+oEbmj+Gg1LV3/dSoNBD3Qyoe+9sP
ZqfxhDjRTv+qXkMj+psA49xGt13JRLxUsU9BsfwNJJY7WtMOfy88nyDTtQSabXUz55chbSjvR7Su
RuJw3JOOP4QQa+nO4AlqDnUI9wwrLlobi/U0xu0MWeXYtWR6gD5A7IH3IZUqypriXIJRqBrEXSwG
lgnnPJZ99L1Eeu6ZxbLAVyW+4u43qRGJSvLMxzxbGGhuDxCpefntHhRWtxHMA63ARv0QZzSWONQQ
R+1E0ACguD5jIkYAAAAAAAA=

--Apple-Mail-11--443025249--
