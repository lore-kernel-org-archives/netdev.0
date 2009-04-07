From: Sergio Monteiro Basto <sergio@sergiomb.no-ip.org>
Subject: Re: [Bugme-new] [Bug 12969] New: WARNING: at lib/dma-debug.c:539
 check_sync+0xe9/0x341() (Not tainted)
Date: Tue, 07 Apr 2009 15:31:49 +0100
Message-ID: <1239114709.3638.5.camel@segulix>
References: <bug-12969-10286@http.bugzilla.kernel.org/>
	 <20090401165015.8481f9e0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature"; boundary="=-kTVay/aSL0CTA4GUy3aZ"
Cc: zambrano@broadcom.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, Joerg Roedel <joerg.roedel@amd.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4.ptmail.sapo.pt ([212.55.154.24]:54869 "HELO sapo.pt"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752663AbZDGOb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 10:31:59 -0400
In-Reply-To: <20090401165015.8481f9e0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kTVay/aSL0CTA4GUy3aZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable


+ b44-use-kernel-dma-addresses-for-the-kernel-dma-api.patch added to -mm
tree

fixes the bug for me=20

Thanks,=20


On Wed, 2009-04-01 at 16:50 -0700, Andrew Morton wrote:

> On Sun, 29 Mar 2009 11:43:19 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > http://bugzilla.kernel.org/show_bug.cgi?id=3D12969
> >=20
> >            Summary: WARNING: at lib/dma-debug.c:539
> >                     check_sync+0xe9/0x341() (Not tainted)
> >            Product: Drivers
> >            Version: 2.5
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Fedora
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: sergio@sergiomb.no-ip.org
> >         Regression: Yes
> >=20
> >=20
> > ------------[ cut
> here ]------------                                           =20
> > WARNING: at lib/dma-debug.c:539 check_sync+0xe9/0x341() (Not
> tainted)          =20
> > Hardware name: HP Compaq nx6110
> (PY501EA#AB9)                                  =20
> > b44 0000:02:0e.0: DMA-API: device driver tries to sync DMA memory it
> has not
> > allocated [device address=3D0x0000000075941040] [size=3D1566 bytes] =20
> > Modules linked in: llc bnep l2cap bluetooth autofs4 lm90 hwmon
> i2c_i801 sunrpc
> > ipv6 cpufreq_ondemand acpi_cpufreq uinput snd_intel8x0m snd_intel8x0
> > snd_ac97_codec snd_seq_dummy ac97_bus snd_seq_oss snd_seq_midi_event
> snd_seq
> > snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm b44 ssb
> firewire_ohci
> > snd_timer ipw2200 iTCO_wdt mii firewire_core snd iTCO_vendor_support
> libipw
> > yenta_socket crc_itu_t lib80211 rsrc_nonstatic soundcore
> snd_page_alloc joydev
> > pcspkr wmi serio_raw ata_generic pata_acpi i915 drm i2c_algo_bit
> i2c_core video
> > output [last unloaded:
> scsi_wait_scan]                                         =20
> > Pid: 2418, comm: S58ntpd Not tainted 2.6.29-16.fc10.i686.PAE
> #1                =20
> > Call
> Trace:                                                                   =
 =20
> >  [<c04396d1>] warn_slowpath
> +0x7c/0xbd                                          =20
> >  [<c0457fe1>] ? register_lock_class
> +0x17/0x290                                 =20
> >  [<c0458d61>] ? mark_lock
> +0x1e/0x349                                           =20
> >  [<c0556448>] ? _raw_spin_unlock
> +0x74/0x78                                     =20
> >  [<c0458d61>] ? mark_lock
> +0x1e/0x349                                           =20
> >  [<c055a060>] ? check_sync
> +0x37/0x341                                          =20
> >  [<c055a112>] check_sync
> +0xe9/0x341                                            =20
> >  [<c0711245>] ? _spin_unlock_irqrestore
> +0x45/0x55                              =20
> >  [<c04592db>] ? trace_hardirqs_on
> +0xb/0xd                                      =20
> >  [<c055a4d1>] debug_dma_sync_single_for_device
> +0x2f/0x39                       =20
> >  [<f828f722>] dma_sync_single_for_device+0x4a/0x59
> [b44]                       =20
> >  [<f828f76f>] ssb_dma_sync_single_for_device+0x3e/0x48
> [b44]                   =20
> >  [<f8291d1e>] b44_recycle_rx+0x18c/0x196
> [b44]                                 =20
> >  [<f8291f9f>] b44_poll+0x277/0x3c0
> [b44]                                       =20
> >  [<c0687bb9>] net_rx_action
> +0xa1/0x1ca                                         =20
> >  [<c043e30a>] __do_softirq
> +0x9d/0x154                                          =20
> >  [<c043e413>] do_softirq
> +0x52/0x7e                                             =20
> >  [<c043e56f>] irq_exit
> +0x49/0x77                                               =20
> >  [<c040b22e>] do_IRQ
> +0x97/0xad                                                 =20
> >  [<c0409dac>] common_interrupt
> +0x2c/0x34                                       =20
>=20
> This would appear to be reporting a bug in b44's DMA API usage.  See
> the newly-added documentation in Documentation/DMA-API.txt, starting
> with
>=20
>         Part III - Debug drivers use of the DMA-API
>=20
> The line numbers have changed, but it is:
>=20
>                 err_printk(ref->dev, NULL, "DMA-API: device driver
> tries "
>                            "to free DMA memory it has not allocated "
>                            "[device address=3D0x%016llx] [size=3D%llu
> bytes]\n",
>                            ref->dev_addr, ref->size);
>=20
--=20
S=C3=A9rgio M. B.

--=-kTVay/aSL0CTA4GUy3aZ
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGVjCCAw8w
ggJ4oAMCAQICEA6CVh3keQ8TFtyrh/wrbgYwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkEx
JTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA4MTAxNDAzMTc0N1oXDTA5MTAxNDAzMTc0
N1owSzEfMB0GA1UEAxMWVGhhd3RlIEZyZWVtYWlsIE1lbWJlcjEoMCYGCSqGSIb3DQEJARYZc2Vy
Z2lvQHNlcmdpb21iLm5vLWlwLm9yZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ2D
rpizYnrRUFYQm6b6ZcE50ta36mutS13FIAqg0ugCjlSFSv+nkjbfEBOug+hb5vh9SOBOLy+UFJrn
2MibIuLGip4OsawcJ41Z7prkKlUCIwtNLmb/m7swubSLqFRiojy0ctMhMWtDt9xzwOYmZN7yGMiS
jFHivrtZRGPWA7tPzN3KOQeSP4DYxLZ06a3ZOwqR4g3NkQeWbdLVvBe6r3mKtaoDeirW5XT8epyh
vqRK7izl/vOum2Gx+HeaLpyH5pTOhMd2K7DTfMiBjqBxchUDTccOykMN+5i9ketxy3Bh0PfEStZh
vjaZbCsJIV2WQc/jAH+k3xef41fci2o+Cz0CAwEAAaNZMFcwDgYDVR0PAQH/BAQDAgSQMBEGCWCG
SAGG+EIBAQQEAwIFoDAkBgNVHREEHTAbgRlzZXJnaW9Ac2VyZ2lvbWIubm8taXAub3JnMAwGA1Ud
EwEB/wQCMAAwDQYJKoZIhvcNAQEFBQADgYEAABP+jrmaOnO/2yM7OeJmjEVjDJpT2baLpvBL1k4O
6HSVgsx5JidSa+vF/cKaP1UFko8XT2TooDpnrTbw//Rkfd6ZbeXXqzdIJQs4xiSRGgcMuJL8GtuH
LQHkOIqKaPW+KSzVG68U/NzSzqdtr5iPwE6YCLMN0WnVduhgLQlXqkAwggM/MIICqKADAgECAgEN
MA0GCSqGSIb3DQEBBQUAMIHRMQswCQYDVQQGEwJaQTEVMBMGA1UECBMMV2VzdGVybiBDYXBlMRIw
EAYDVQQHEwlDYXBlIFRvd24xGjAYBgNVBAoTEVRoYXd0ZSBDb25zdWx0aW5nMSgwJgYDVQQLEx9D
ZXJ0aWZpY2F0aW9uIFNlcnZpY2VzIERpdmlzaW9uMSQwIgYDVQQDExtUaGF3dGUgUGVyc29uYWwg
RnJlZW1haWwgQ0ExKzApBgkqhkiG9w0BCQEWHHBlcnNvbmFsLWZyZWVtYWlsQHRoYXd0ZS5jb20w
HhcNMDMwNzE3MDAwMDAwWhcNMTMwNzE2MjM1OTU5WjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMc
VGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZy
ZWVtYWlsIElzc3VpbmcgQ0EwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAMSmPFVzVftOucqZ
Wh5owHUEcJ3f6f+jHuy9zfVb8hp2vX8MOmHyv1HOAdTlUAow1wJjWiyJFXCO3cnwK4Vaqj9xVsuv
PAsH5/EfkTYkKhPPK9Xzgnc9A74r/rsYPge/QIACZNenprufZdHFKlSFD0gEf6e20TxhBEAeZBly
YLf7AgMBAAGjgZQwgZEwEgYDVR0TAQH/BAgwBgEB/wIBADBDBgNVHR8EPDA6MDigNqA0hjJodHRw
Oi8vY3JsLnRoYXd0ZS5jb20vVGhhd3RlUGVyc29uYWxGcmVlbWFpbENBLmNybDALBgNVHQ8EBAMC
AQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEVByaXZhdGVMYWJlbDItMTM4MA0GCSqGSIb3DQEB
BQUAA4GBAEiM0VCD6gsuzA2jZqxnD3+vrL7CF6FDlpSdf0whuPg2H6otnzYvwPQcUCCTcDz9reFh
YsPZOhl+hLGZGwDFGguCdJ4lUJRix9sncVcljd2pnDmOjCBPZV+V2vf3h9bGCE6u9uo05RAaWzVN
d+NWIXiC3CEZNd4ksdMdRv9dX2VPMYIB/DCCAfgCAQEwdjBiMQswCQYDVQQGEwJaQTElMCMGA1UE
ChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFs
IEZyZWVtYWlsIElzc3VpbmcgQ0ECEA6CVh3keQ8TFtyrh/wrbgYwCQYFKw4DAhoFAKBdMBgGCSqG
SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA5MDQwNzE0MzE0OVowIwYJKoZI
hvcNAQkEMRYEFMsqKXMpdmx9GynbUpkR9NanHeCSMA0GCSqGSIb3DQEBAQUABIIBAAUh5g/LXm+e
uNx9rSQmfhukFMFAd0S6mDYaXMb/GGyLenlHx8o0A/IuvZJdd5BFt+KdPHf3wHRCw8nr7nAziAuZ
j4AekfpmHrQ9J00J7ydLBrxzdcfmH+Ds0PKQAy9Bad7JfadHFp04xyYneU0Fceli191HDw1oxfJO
yPbwwLoVprqAC7tmHVi1BF2M9uxRSRPAnCpvI6dUPQ+7zaPoGzXNhCSvCAwKYQpKGnWxy/kZFb4g
GaoZlvafHcRCxxFZdUh9hLRl2rhcTjaHWRIPyY+jyjXIdvAtYzz/ckKl2dEECdJFk0SOd2OKPNU4
kpTVA+PcUt5SYaEEo6wAg6M2sCQAAAAAAAA=


--=-kTVay/aSL0CTA4GUy3aZ--

