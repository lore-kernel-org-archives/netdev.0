From: Andreas Unterluggauer <au@unterluggauer.org>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Mon, 31 Jan 2005 16:40:16 +0100
Message-ID: <200501311640.16118.au@unterluggauer.org>
References: <E1CvZCT-00017g-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_gFl/Bi96WSERiIA"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CvZCT-00017g-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_gFl/Bi96WSERiIA
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Herbert,

> for me it looks like racoon doesn't get the SADB_ACQUIRE message. 
for the log-file in the last message I made a ping from the remote computer, 
that's the reason why there is no SADB_ACQUIRE message.

now I have attached a log-file from a ping to the remote computer. there you 
can see that racoon is getting one ACQUIRE message (and then generating two 
SA's?)

cheers
andi

--Boundary-00=_gFl/Bi96WSERiIA
Content-Type: text/x-log;
  charset="iso-8859-1";
  name="racoon2.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="racoon2.log"

2005-01-31 16:29:35: INFO: @(#)ipsec-tools 0.5rc2 (http://ipsec-tools.sourceforge.net)
2005-01-31 16:29:35: INFO: @(#)This product linked OpenSSL 0.9.7a Feb 19 2003 (http://www.openssl.org/)
2005-01-31 16:29:35: DEBUG: call pfkey_send_register for AH
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 7, p->sadb_msg_satype: 2, seq: 0)
2005-01-31 16:29:36: DEBUG: call pfkey_send_register for ESP
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 7, p->sadb_msg_satype: 3, seq: 0)
2005-01-31 16:29:36: DEBUG: call pfkey_send_register for IPCOMP
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 7, p->sadb_msg_satype: 9, seq: 0)
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 18, p->sadb_msg_satype: 0, seq: 0)
2005-01-31 16:29:36: DEBUG: reading config file racoon.conf
2005-01-31 16:29:36: DEBUG: hmac(modp1024)
2005-01-31 16:29:36: DEBUG: compression algorithm can not be checked because sadb message doesn't support it.
2005-01-31 16:29:36: DEBUG: my interface: 127.0.0.1 (lo)
2005-01-31 16:29:36: DEBUG: my interface: 192.168.2.5 (eth0)
2005-01-31 16:29:36: DEBUG: configuring default isakmp port.
2005-01-31 16:29:36: DEBUG: 2 addrs are configured successfully
2005-01-31 16:29:36: INFO: 192.168.2.5[500] used as isakmp port (fd=6)
2005-01-31 16:29:36: INFO: 127.0.0.1[500] used as isakmp port (fd=7)
2005-01-31 16:29:36: DEBUG: get pfkey X_SPDDUMP message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 18)
2005-01-31 16:29:36: DEBUG: get pfkey X_SPDDUMP message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 18)
2005-01-31 16:29:36: DEBUG: sub:0xbff871a0: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 16:29:36: DEBUG: db :0x862a650: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 16:29:36: DEBUG: get pfkey X_SPDDUMP message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 18)
2005-01-31 16:29:36: DEBUG: sub:0xbff871a0: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=fwd
2005-01-31 16:29:36: DEBUG: db :0x862a650: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 16:29:36: DEBUG: sub:0xbff871a0: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=fwd
2005-01-31 16:29:36: DEBUG: db :0x862a9a8: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 16:29:56: DEBUG: get pfkey ACQUIRE message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 6)
2005-01-31 16:29:56: DEBUG: andi: pfkey.c, pk_recvacquire: start.
2005-01-31 16:29:56: DEBUG: suitable outbound SP found: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out.
2005-01-31 16:29:56: DEBUG: sub:0xbff87180: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 16:29:56: DEBUG: db :0x862a650: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 16:29:56: DEBUG: suitable inbound SP found: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in.
2005-01-31 16:29:56: INFO: andi: in pfkey.c, pk_recvacquire: n=0, iph2[n]->seq=2
2005-01-31 16:29:56: INFO: andi: spid=761, satype=3
2005-01-31 16:29:56: DEBUG: new acquire 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 16:29:56: DEBUG: anonymous sainfo selected.
2005-01-31 16:29:56: DEBUG:  (proto_id=AH spisize=4 spi=00000000 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 16:29:56: DEBUG:   (trns_id=SHA authtype=hmac-sha)
2005-01-31 16:29:56: DEBUG:  (proto_id=ESP spisize=4 spi=00000000 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 16:29:56: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-sha)
2005-01-31 16:29:56: DEBUG: anonymous configuration selected for 192.168.2.3.
2005-01-31 16:29:56: INFO: IPsec-SA request for 192.168.2.3 queued due to no phase1 found.
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: INFO: initiate new phase 1 negotiation: 192.168.2.5[500]<=>192.168.2.3[500]
2005-01-31 16:29:56: INFO: begin Identity Protection mode.
2005-01-31 16:29:56: DEBUG: new cookie:
6c9b61569b3a8f1e
2005-01-31 16:29:56: DEBUG: add payload of len 48, next type 0
2005-01-31 16:29:56: DEBUG: 80 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: sockname 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: src4 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: dst4 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: 1 times of 80 bytes message will be sent to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e 00000000 00000000 01100200 00000000 00000050 00000034
00000001 00000001 00000028 01010001 00000020 01010000 800b0001 800c1c20
80010005 80030001 80020002 80040002
2005-01-31 16:29:56: DEBUG: resend phase1 packet 6c9b61569b3a8f1e:0000000000000000
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: 80 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 01100200 00000000 00000050 00000034
00000001 00000001 00000028 01010001 00000020 01010000 800b0001 800c1c20
80010005 80030001 80020002 80040002
2005-01-31 16:29:56: DEBUG: begin.
2005-01-31 16:29:56: DEBUG: seen nptype=1(sa)
2005-01-31 16:29:56: DEBUG: succeed.
2005-01-31 16:29:56: DEBUG: total SA len=48
2005-01-31 16:29:56: DEBUG:
00000001 00000001 00000028 01010001 00000020 01010000 800b0001 800c1c20
80010005 80030001 80020002 80040002
2005-01-31 16:29:56: DEBUG: begin.
2005-01-31 16:29:56: DEBUG: seen nptype=2(prop)
2005-01-31 16:29:56: DEBUG: succeed.
2005-01-31 16:29:56: DEBUG: proposal #1 len=40
2005-01-31 16:29:56: DEBUG: begin.
2005-01-31 16:29:56: DEBUG: seen nptype=3(trns)
2005-01-31 16:29:56: DEBUG: succeed.
2005-01-31 16:29:56: DEBUG: transform #1 len=32
2005-01-31 16:29:56: DEBUG: type=Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:56: DEBUG: type=Life Duration, flag=0x8000, lorv=7200
2005-01-31 16:29:56: DEBUG: type=Encryption Algorithm, flag=0x8000, lorv=3DES-CBC
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: type=Authentication Method, flag=0x8000, lorv=pre-shared key
2005-01-31 16:29:56: DEBUG: type=Hash Algorithm, flag=0x8000, lorv=SHA
2005-01-31 16:29:56: DEBUG: hash(sha1)
2005-01-31 16:29:56: DEBUG: type=Group Description, flag=0x8000, lorv=1024-bit MODP group
2005-01-31 16:29:56: DEBUG: hmac(modp1024)
2005-01-31 16:29:56: DEBUG: pair 1:
2005-01-31 16:29:56: DEBUG:  0x862b898: next=(nil) tnext=(nil)
2005-01-31 16:29:56: DEBUG: proposal #1: 1 transform
2005-01-31 16:29:56: DEBUG: prop#=1, prot-id=ISAKMP, spi-size=0, #trns=1
2005-01-31 16:29:56: DEBUG: trns#=1, trns-id=IKE
2005-01-31 16:29:56: DEBUG: type=Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:56: DEBUG: type=Life Duration, flag=0x8000, lorv=7200
2005-01-31 16:29:56: DEBUG: type=Encryption Algorithm, flag=0x8000, lorv=3DES-CBC
2005-01-31 16:29:56: DEBUG: type=Authentication Method, flag=0x8000, lorv=pre-shared key
2005-01-31 16:29:56: DEBUG: type=Hash Algorithm, flag=0x8000, lorv=SHA
2005-01-31 16:29:56: DEBUG: type=Group Description, flag=0x8000, lorv=1024-bit MODP group
2005-01-31 16:29:56: DEBUG: Compared: DB:Peer
2005-01-31 16:29:56: DEBUG: (lifetime = 7200:7200)
2005-01-31 16:29:56: DEBUG: (lifebyte = 0:0)
2005-01-31 16:29:56: DEBUG: enctype = 3DES-CBC:3DES-CBC
2005-01-31 16:29:56: DEBUG: (encklen = 0:0)
2005-01-31 16:29:56: DEBUG: hashtype = SHA:SHA
2005-01-31 16:29:56: DEBUG: authmethod = pre-shared key:pre-shared key
2005-01-31 16:29:56: DEBUG: dh_group = 1024-bit MODP group:1024-bit MODP group
2005-01-31 16:29:56: DEBUG: an acceptable proposal found.
2005-01-31 16:29:56: DEBUG: hmac(modp1024)
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: compute DH's private.
2005-01-31 16:29:56: DEBUG:
60f7d969 73f80465 2ae88214 af0716e9 4f7f3925 aa2963a3 b982ad97 5870191f
f4688758 763997f2 3d138df7 dcf765de d83b2b05 ca463837 5feda28b 8b884432
8f4581f3 3357caca 868d1595 49f8b049 802fe55a d75f7f2d e93d43f6 5174eee1
4cd02e4d f4a05f79 0de5add8 a6521e22 3ee09e57 c362b866 fb491411 17694feb
2005-01-31 16:29:56: DEBUG: compute DH's public.
2005-01-31 16:29:56: DEBUG:
3ea0f424 d7a63ac8 1ddfd00f 568f5241 76b06d85 f61391fb f673af15 27dd28e5
78990eec afdfb902 a7be1c40 fb1b14d3 79ce8030 34d67426 3cbff91b 05d4ac3a
1a647370 3521737a fa87dcd4 2ab4351d 5e007a59 d3deee78 635b5aa3 53621cc5
b4cd76d9 50595c1f b955e1ac 100c2d28 fb9c9174 e919e18e f72d3f58 192bb64f
2005-01-31 16:29:56: DEBUG: add payload of len 128, next type 10
2005-01-31 16:29:56: DEBUG: add payload of len 16, next type 0
2005-01-31 16:29:56: DEBUG: 180 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: sockname 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: src4 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: dst4 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: 1 times of 180 bytes message will be sent to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 04100200 00000000 000000b4 0a000084
3ea0f424 d7a63ac8 1ddfd00f 568f5241 76b06d85 f61391fb f673af15 27dd28e5
78990eec afdfb902 a7be1c40 fb1b14d3 79ce8030 34d67426 3cbff91b 05d4ac3a
1a647370 3521737a fa87dcd4 2ab4351d 5e007a59 d3deee78 635b5aa3 53621cc5
b4cd76d9 50595c1f b955e1ac 100c2d28 fb9c9174 e919e18e f72d3f58 192bb64f
00000014 ac4bbee1 f7b8f75e e83611f6 3644828e
2005-01-31 16:29:56: DEBUG: resend phase1 packet 6c9b61569b3a8f1e:be23bf6c739326c6
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: 180 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 04100200 00000000 000000b4 0a000084
1f3e1c57 1edef355 839a4bd6 b99446ea 4dc4ad07 c2d67d0d ccdf3d12 b0a76896
2f5e9e44 a1043eed e14a8030 79a5aa71 bef01b18 8278f9c4 66bc49b9 8fece4b3
7729072e 2e5ec10e 42bf9a80 e6e1ad9d 1fb6e238 7af196f8 98ea5e8d 148071e1
e3e6967f 20510103 a517d98d 9e13ba6d abc970f9 52b58329 32228ceb fff14a13
00000014 ece04032 83a5d64c e3443a73 c64531ad
2005-01-31 16:29:56: DEBUG: begin.
2005-01-31 16:29:56: DEBUG: seen nptype=4(ke)
2005-01-31 16:29:56: DEBUG: seen nptype=10(nonce)
2005-01-31 16:29:56: DEBUG: succeed.
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: compute DH's shared.
2005-01-31 16:29:56: DEBUG:
c6e02605 557a12bd 6f587688 3f8e2625 0353d200 9399d55d ffa60a72 9dd42a0a
3b041f36 555e03aa ef68b6dc e1d443cc 5561e805 58ea2fe0 57f9a996 73dc50f8
59d5c0b6 6106e7c9 468984b1 379bd2f5 9373fbb0 62982f27 931ddabf ca385290
e007dcac 7f558199 afd055e5 fa41c33a 016ec19a fc00b62e dd039f20 c7e708e8
2005-01-31 16:29:56: DEBUG: the psk found.
2005-01-31 16:29:56: DEBUG: nonce 1: 2005-01-31 16:29:56: DEBUG:
ac4bbee1 f7b8f75e e83611f6 3644828e
2005-01-31 16:29:56: DEBUG: nonce 2: 2005-01-31 16:29:56: DEBUG:
ece04032 83a5d64c e3443a73 c64531ad
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: SKEYID computed:
2005-01-31 16:29:56: DEBUG:
003bb469 b8f3a172 7b6f780c 5d393a0b 9329baeb
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: SKEYID_d computed:
2005-01-31 16:29:56: DEBUG:
2a712766 e9180f0c 7cc89731 da3c10ad 7569efbc
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: SKEYID_a computed:
2005-01-31 16:29:56: DEBUG:
bc9a9f36 417e3df8 394f1b76 75df267b 6d46a745
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: SKEYID_e computed:
2005-01-31 16:29:56: DEBUG:
570541d4 6a6ad98d 26642038 da9bf06b d12e42c2
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: hash(sha1)
2005-01-31 16:29:56: DEBUG: len(SKEYID_e) < len(Ka) (20 < 24), generating long key (Ka = K1 | K2 | ...)
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: compute intermediate encryption key K1
2005-01-31 16:29:56: DEBUG:
00
2005-01-31 16:29:56: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: compute intermediate encryption key K2
2005-01-31 16:29:56: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8
2005-01-31 16:29:56: DEBUG:
f3ac42fa 685f0c8d 18924d32 b7f52bb5 5326d31a
2005-01-31 16:29:56: DEBUG: final encryption key computed:
2005-01-31 16:29:56: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:56: DEBUG: hash(sha1)
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: IV computed:
2005-01-31 16:29:56: DEBUG:
29a8fe0b 68b537b7
2005-01-31 16:29:56: DEBUG: use ID type of IPv4_address
2005-01-31 16:29:56: DEBUG: HASH with:
2005-01-31 16:29:56: DEBUG:
3ea0f424 d7a63ac8 1ddfd00f 568f5241 76b06d85 f61391fb f673af15 27dd28e5
78990eec afdfb902 a7be1c40 fb1b14d3 79ce8030 34d67426 3cbff91b 05d4ac3a
1a647370 3521737a fa87dcd4 2ab4351d 5e007a59 d3deee78 635b5aa3 53621cc5
b4cd76d9 50595c1f b955e1ac 100c2d28 fb9c9174 e919e18e f72d3f58 192bb64f
1f3e1c57 1edef355 839a4bd6 b99446ea 4dc4ad07 c2d67d0d ccdf3d12 b0a76896
2f5e9e44 a1043eed e14a8030 79a5aa71 bef01b18 8278f9c4 66bc49b9 8fece4b3
7729072e 2e5ec10e 42bf9a80 e6e1ad9d 1fb6e238 7af196f8 98ea5e8d 148071e1
e3e6967f 20510103 a517d98d 9e13ba6d abc970f9 52b58329 32228ceb fff14a13
6c9b6156 9b3a8f1e be23bf6c 739326c6 00000001 00000001 00000028 01010001
00000020 01010000 800b0001 800c1c20 80010005 80030001 80020002 80040002
011101f4 c0a80205
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: HASH computed:
2005-01-31 16:29:56: DEBUG:
39be6a33 3e209d6a 5ccd53f4 1b08ec90 36e5da92
2005-01-31 16:29:56: DEBUG: add payload of len 8, next type 8
2005-01-31 16:29:56: DEBUG: add payload of len 20, next type 0
2005-01-31 16:29:56: DEBUG: begin encryption.
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: pad length = 4
2005-01-31 16:29:56: DEBUG:
0800000c 011101f4 c0a80205 00000018 39be6a33 3e209d6a 5ccd53f4 1b08ec90
36e5da92 b9a68703
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: with key:
2005-01-31 16:29:56: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:56: DEBUG: encrypted payload by IV:
2005-01-31 16:29:56: DEBUG:
29a8fe0b 68b537b7
2005-01-31 16:29:56: DEBUG: save IV for next:
2005-01-31 16:29:56: DEBUG:
2b125b91 7a8b9ebd
2005-01-31 16:29:56: DEBUG: encrypted.
2005-01-31 16:29:56: DEBUG: 68 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: sockname 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: src4 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: dst4 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: 1 times of 68 bytes message will be sent to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 05100201 00000000 00000044 5ec981b2
fdd33b68 1544c131 964fe8e2 64df498c 597b4959 4d8972b0 7bfe3c9d 2b125b91
7a8b9ebd
2005-01-31 16:29:56: DEBUG: resend phase1 packet 6c9b61569b3a8f1e:be23bf6c739326c6
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: 68 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 05100201 00000000 00000044 65138087
62f9b823 ad529137 0ead6d2a b9159dc1 c1485032 89d39648 aba88945 ec7dbbee
437705e2
2005-01-31 16:29:56: DEBUG: begin decryption.
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: IV was saved for next processing:
2005-01-31 16:29:56: DEBUG:
ec7dbbee 437705e2
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: with key:
2005-01-31 16:29:56: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:56: DEBUG: decrypted payload by IV:
2005-01-31 16:29:56: DEBUG:
2b125b91 7a8b9ebd
2005-01-31 16:29:56: DEBUG: decrypted payload, but not trimed.
2005-01-31 16:29:56: DEBUG:
0800000c 011101f4 c0a80203 00000018 66059430 a61e698c 6a09b8c8 9c40bc2e
fd51bfb2 ebf9a403
2005-01-31 16:29:56: DEBUG: padding len=4
2005-01-31 16:29:56: DEBUG: skip to trim padding.
2005-01-31 16:29:56: DEBUG: decrypted.
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 05100201 00000000 00000044 0800000c
011101f4 c0a80203 00000018 66059430 a61e698c 6a09b8c8 9c40bc2e fd51bfb2
ebf9a403
2005-01-31 16:29:56: DEBUG: begin.
2005-01-31 16:29:56: DEBUG: seen nptype=5(id)
2005-01-31 16:29:56: DEBUG: seen nptype=8(hash)
2005-01-31 16:29:56: DEBUG: succeed.
2005-01-31 16:29:56: DEBUG: HASH received:2005-01-31 16:29:56: DEBUG:
66059430 a61e698c 6a09b8c8 9c40bc2e fd51bfb2
2005-01-31 16:29:56: DEBUG: HASH with:
2005-01-31 16:29:56: DEBUG:
1f3e1c57 1edef355 839a4bd6 b99446ea 4dc4ad07 c2d67d0d ccdf3d12 b0a76896
2f5e9e44 a1043eed e14a8030 79a5aa71 bef01b18 8278f9c4 66bc49b9 8fece4b3
7729072e 2e5ec10e 42bf9a80 e6e1ad9d 1fb6e238 7af196f8 98ea5e8d 148071e1
e3e6967f 20510103 a517d98d 9e13ba6d abc970f9 52b58329 32228ceb fff14a13
3ea0f424 d7a63ac8 1ddfd00f 568f5241 76b06d85 f61391fb f673af15 27dd28e5
78990eec afdfb902 a7be1c40 fb1b14d3 79ce8030 34d67426 3cbff91b 05d4ac3a
1a647370 3521737a fa87dcd4 2ab4351d 5e007a59 d3deee78 635b5aa3 53621cc5
b4cd76d9 50595c1f b955e1ac 100c2d28 fb9c9174 e919e18e f72d3f58 192bb64f
be23bf6c 739326c6 6c9b6156 9b3a8f1e 00000001 00000001 00000028 01010001
00000020 01010000 800b0001 800c1c20 80010005 80030001 80020002 80040002
011101f4 c0a80203
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: HASH computed:
2005-01-31 16:29:56: DEBUG:
66059430 a61e698c 6a09b8c8 9c40bc2e fd51bfb2
2005-01-31 16:29:56: DEBUG: HASH for PSK validated.
2005-01-31 16:29:56: DEBUG: peer's ID:2005-01-31 16:29:56: DEBUG:
011101f4 c0a80203
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: compute IV for phase2
2005-01-31 16:29:56: DEBUG: phase1 last IV:
2005-01-31 16:29:56: DEBUG:
ec7dbbee 437705e2 89f3c58d
2005-01-31 16:29:56: DEBUG: hash(sha1)
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: phase2 IV computed:
2005-01-31 16:29:56: DEBUG:
3fa6b89d 32e87d86
2005-01-31 16:29:56: DEBUG: HASH with:
2005-01-31 16:29:56: DEBUG:
89f3c58d 0000001c 00000001 01106002 6c9b6156 9b3a8f1e be23bf6c 739326c6
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: HASH computed:
2005-01-31 16:29:56: DEBUG:
7ed2c692 3fe16dd2 e46593a9 573d6a88 a510128d
2005-01-31 16:29:56: DEBUG: begin encryption.
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: pad length = 4
2005-01-31 16:29:56: DEBUG:
0b000018 7ed2c692 3fe16dd2 e46593a9 573d6a88 a510128d 0000001c 00000001
01106002 6c9b6156 9b3a8f1e be23bf6c 739326c6 d6ca9b03
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: with key:
2005-01-31 16:29:56: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:56: DEBUG: encrypted payload by IV:
2005-01-31 16:29:56: DEBUG:
3fa6b89d 32e87d86
2005-01-31 16:29:56: DEBUG: save IV for next:
2005-01-31 16:29:56: DEBUG:
e2bed52a dea2cc72
2005-01-31 16:29:56: DEBUG: encrypted.
2005-01-31 16:29:56: DEBUG: 84 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: sockname 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: src4 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG: dst4 192.168.2.3[500]
2005-01-31 16:29:56: DEBUG: 1 times of 84 bytes message will be sent to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 08100501 89f3c58d 00000054 fbdc170e
36e67786 e622c244 8a878f1f b7fbbef4 4642efc4 9cf67fa5 da0495b1 3620a46d
52dea759 6d57815f 0ca417f8 e2bed52a dea2cc72
2005-01-31 16:29:56: DEBUG: sendto Information notify.
2005-01-31 16:29:56: INFO: ISAKMP-SA established 192.168.2.5[500]-192.168.2.3[500] spi:6c9b61569b3a8f1e:be23bf6c739326c6
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: ===
2005-01-31 16:29:56: DEBUG: 84 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 08100501 91e46358 00000054 40d05ae5
185847e2 164bcd53 5b6939e4 9a4acda0 dd2dd242 2e8d4672 a4ae182c bf25a4f2
10297d6b fb884828 0386e672 a66fc0a6 98ff04f7
2005-01-31 16:29:56: DEBUG: receive Information.
2005-01-31 16:29:56: DEBUG: compute IV for phase2
2005-01-31 16:29:56: DEBUG: phase1 last IV:
2005-01-31 16:29:56: DEBUG:
ec7dbbee 437705e2 91e46358
2005-01-31 16:29:56: DEBUG: hash(sha1)
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: phase2 IV computed:
2005-01-31 16:29:56: DEBUG:
f017f542 91fd6b14
2005-01-31 16:29:56: DEBUG: begin decryption.
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: IV was saved for next processing:
2005-01-31 16:29:56: DEBUG:
a66fc0a6 98ff04f7
2005-01-31 16:29:56: DEBUG: encryption(3des)
2005-01-31 16:29:56: DEBUG: with key:
2005-01-31 16:29:56: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:56: DEBUG: decrypted payload by IV:
2005-01-31 16:29:56: DEBUG:
f017f542 91fd6b14
2005-01-31 16:29:56: DEBUG: decrypted payload, but not trimed.
2005-01-31 16:29:56: DEBUG:
0b000018 94d8c097 8b1c2814 0426019c 931a39c2 c60f66cf 0000001c 00000001
01106002 6c9b6156 9b3a8f1e be23bf6c 739326c6 c6ebef03
2005-01-31 16:29:56: DEBUG: padding len=4
2005-01-31 16:29:56: DEBUG: skip to trim padding.
2005-01-31 16:29:56: DEBUG: decrypted.
2005-01-31 16:29:56: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 08100501 91e46358 00000054 0b000018
94d8c097 8b1c2814 0426019c 931a39c2 c60f66cf 0000001c 00000001 01106002
6c9b6156 9b3a8f1e be23bf6c 739326c6 c6ebef03
2005-01-31 16:29:56: DEBUG: HASH with:
2005-01-31 16:29:56: DEBUG:
91e46358 0000001c 00000001 01106002 6c9b6156 9b3a8f1e be23bf6c 739326c6
2005-01-31 16:29:56: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:56: DEBUG: HASH computed:
2005-01-31 16:29:56: DEBUG:
94d8c097 8b1c2814 0426019c 931a39c2 c60f66cf
2005-01-31 16:29:56: DEBUG: hash validated.
2005-01-31 16:29:56: DEBUG: begin.
2005-01-31 16:29:56: DEBUG: seen nptype=8(hash)
2005-01-31 16:29:56: DEBUG: seen nptype=11(notify)
2005-01-31 16:29:56: DEBUG: succeed.
2005-01-31 16:29:56: DEBUG: call pfkey_send_dump
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 10, p->sadb_msg_satype: 0, seq: 0)
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 10)
2005-01-31 16:29:56: DEBUG: notification message 24578:INITIAL-CONTACT, doi=1 proto_id=1 spi=6c9b61569b3a8f1e be23bf6c739326c6 (size=16).
2005-01-31 16:29:57: DEBUG: ===
2005-01-31 16:29:57: DEBUG: begin QUICK mode.
2005-01-31 16:29:57: INFO: initiate new phase 2 negotiation: 192.168.2.5[0]<=>192.168.2.3[0]
2005-01-31 16:29:57: DEBUG: compute IV for phase2
2005-01-31 16:29:57: DEBUG: phase1 last IV:
2005-01-31 16:29:57: DEBUG:
ec7dbbee 437705e2 c4e55a01
2005-01-31 16:29:57: DEBUG: hash(sha1)
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: phase2 IV computed:
2005-01-31 16:29:57: DEBUG:
73c9a87b d8ffd124
2005-01-31 16:29:57: DEBUG: andi: pfkey.c, pfkey_send_getspi (pr->proto_id: 2,iph2->seq: 2)
andi: libipsec/pfkey.c, pfkey_send_getspi: (satype: 2, seq: 2)
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 1, p->sadb_msg_satype: 2, seq: 2)
2005-01-31 16:29:57: DEBUG: pfkey GETSPI sent: AH/Transport 192.168.2.3->192.168.2.5
2005-01-31 16:29:57: DEBUG: andi: pfkey.c, pfkey_send_getspi (pr->proto_id: 3,iph2->seq: 2)
andi: libipsec/pfkey.c, pfkey_send_getspi: (satype: 3, seq: 2)
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 1, p->sadb_msg_satype: 3, seq: 2)
2005-01-31 16:29:57: DEBUG: pfkey GETSPI sent: ESP/Transport 192.168.2.3->192.168.2.5
2005-01-31 16:29:57: DEBUG: pfkey getspi sent.
2005-01-31 16:29:57: DEBUG: get pfkey GETSPI message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 1)
2005-01-31 16:29:57: DEBUG: andi: pfkey.c, pk_recvgetspi: msg->sadb_msg_seq 2, msg->sadb_msg_type: GETSPI .
2005-01-31 16:29:57: DEBUG: pfkey GETSPI succeeded: AH/Transport 192.168.2.3->192.168.2.5 spi=123055453(0x755ad5d)
2005-01-31 16:29:57: DEBUG: get pfkey GETSPI message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 1)
2005-01-31 16:29:57: DEBUG: andi: pfkey.c, pk_recvgetspi: msg->sadb_msg_seq 2, msg->sadb_msg_type: GETSPI .
2005-01-31 16:29:57: DEBUG: pfkey GETSPI succeeded: ESP/Transport 192.168.2.3->192.168.2.5 spi=145448323(0x8ab5d83)
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: compute DH's private.
2005-01-31 16:29:57: DEBUG:
60e938bd 0b04792b aa801034 9ada06ff 6717a03b 678f58e8 19435bfc 64545c75
dd0c94ee 53f94709 ef7d052b 2bfc4be4 8a6ad828 9f5a067b 6d03b2a3 0e158e1a
d9bb66d3 506d56d0 a8693f1d 1f77d9a0 ad3cd620 8a7b324d 4e88d63a 61fbd904
ff23138b defbb198 abc5addd 7d878ed3 c05ef310 8be0c616 b958d33f af9f90d1
2005-01-31 16:29:57: DEBUG: compute DH's public.
2005-01-31 16:29:57: DEBUG:
8c92aea1 d09291fd 7563aa3a 5ae7d084 647e501d c8076dd7 b1090266 e3597ca4
5c637f44 6cfa73d5 feb5e271 e0a9db3e 44194000 1eee073e c9eeae5d 028820c5
b8271142 d78a2532 fb2d89f5 eeece32a 46c53178 22c6b0ce 710169ef b64aa667
f94dbfa1 c750c75b 0b7c39f7 8c6d2f3a 067d7b3a d5297cef afc98c46 5fa8362e
2005-01-31 16:29:57: DEBUG: use local ID type IPv4_address
2005-01-31 16:29:57: DEBUG: use remote ID type IPv4_address
2005-01-31 16:29:57: DEBUG: IDci:2005-01-31 16:29:57: DEBUG:
01000000 c0a80205
2005-01-31 16:29:57: DEBUG: IDcr:2005-01-31 16:29:57: DEBUG:
01000000 c0a80203
2005-01-31 16:29:57: DEBUG: add payload of len 88, next type 10
2005-01-31 16:29:57: DEBUG: add payload of len 16, next type 4
2005-01-31 16:29:57: DEBUG: add payload of len 128, next type 0
2005-01-31 16:29:57: DEBUG: HASH with:
2005-01-31 16:29:57: DEBUG:
c4e55a01 0a00005c 00000001 00000001 02000028 01020401 0755ad5d 0000001c
01030000 80010001 80020e10 80040002 80050002 80030002 00000028 01030401
08ab5d83 0000001c 01030000 80010001 80020e10 80040002 80050002 80030002
04000014 e8df8a9c e76da0a2 8c0e0a3a 917629d1 00000084 8c92aea1 d09291fd
7563aa3a 5ae7d084 647e501d c8076dd7 b1090266 e3597ca4 5c637f44 6cfa73d5
feb5e271 e0a9db3e 44194000 1eee073e c9eeae5d 028820c5 b8271142 d78a2532
fb2d89f5 eeece32a 46c53178 22c6b0ce 710169ef b64aa667 f94dbfa1 c750c75b
0b7c39f7 8c6d2f3a 067d7b3a d5297cef afc98c46 5fa8362e
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: HASH computed:
2005-01-31 16:29:57: DEBUG:
6d65b5de 76e1803e f81592ab caf886b4 be40871b
2005-01-31 16:29:57: DEBUG: add payload of len 20, next type 1
2005-01-31 16:29:57: DEBUG: begin encryption.
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: pad length = 4
2005-01-31 16:29:57: DEBUG:
01000018 6d65b5de 76e1803e f81592ab caf886b4 be40871b 0a00005c 00000001
00000001 02000028 01020401 0755ad5d 0000001c 01030000 80010001 80020e10
80040002 80050002 80030002 00000028 01030401 08ab5d83 0000001c 01030000
80010001 80020e10 80040002 80050002 80030002 04000014 e8df8a9c e76da0a2
8c0e0a3a 917629d1 00000084 8c92aea1 d09291fd 7563aa3a 5ae7d084 647e501d
c8076dd7 b1090266 e3597ca4 5c637f44 6cfa73d5 feb5e271 e0a9db3e 44194000
1eee073e c9eeae5d 028820c5 b8271142 d78a2532 fb2d89f5 eeece32a 46c53178
22c6b0ce 710169ef b64aa667 f94dbfa1 c750c75b 0b7c39f7 8c6d2f3a 067d7b3a
d5297cef afc98c46 5fa8362e b6f9b003
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: with key:
2005-01-31 16:29:57: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:57: DEBUG: encrypted payload by IV:
2005-01-31 16:29:57: DEBUG:
73c9a87b d8ffd124
2005-01-31 16:29:57: DEBUG: save IV for next:
2005-01-31 16:29:57: DEBUG:
a9c4ad5d d5b949ec
2005-01-31 16:29:57: DEBUG: encrypted.
2005-01-31 16:29:57: DEBUG: 300 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 16:29:57: DEBUG: sockname 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 16:29:57: DEBUG: src4 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG: dst4 192.168.2.3[500]
2005-01-31 16:29:57: DEBUG: 1 times of 300 bytes message will be sent to 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 08102001 c4e55a01 0000012c 41df7dab
e4a5ba24 4c1bd87f cafa84c1 09eef1b9 7915f73f dac141df bad2f8f1 2e7c7ce0
a4a64cb1 53d483cd b0d107d1 7f422ce6 6ba67296 75377a3d 508bf8fc fedfa848
9ad5aecd 33c07338 90b15431 2a840698 2009a171 bee12883 08ef50e8 11ae3b11
a9bc6e20 650eeb27 8d28fa6f 1b7f2fcb ef20ad59 f5db4d80 95a8f171 dbe1ac88
d83cfe31 8f36a813 98d11b5b ae1906d6 d1d67e15 4ebd391d 5d905ed0 0ae0f9b0
b937b75c 1d090898 2aa8ff25 1d88ab7d 9381a64d 7d75c60b 3b50af96 e0d0f6e2
3b1587bc 5d1015c0 192be00d 54e9b176 84433135 cf864421 d4b28693 725b7b04
83b3228a 9372e46b 6a217c5b 073041e2 3e3f08d3 694eecf8 f6164fc4 3422e096
a0e3b7c0 a9c4ad5d d5b949ec
2005-01-31 16:29:57: DEBUG: resend phase2 packet 6c9b61569b3a8f1e:be23bf6c739326c6:0000c4e5
2005-01-31 16:29:57: DEBUG: ===
2005-01-31 16:29:57: DEBUG: 300 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 08102001 c4e55a01 0000012c ce32691f
8cf44de0 889917dc 08aa06c2 271d8aaf e7d246bc 3fa85a25 1151258e c6e81816
eb2246c9 29497519 aba00c21 17bedc93 b49612d4 39add46c 9d98d032 7f39c23c
3634f729 1dc8521b b92c01d0 51d10b64 8e30b188 b2972363 50d1df7d f5e64f08
68ae0a7e 0fc3ecd4 4cb39f26 8f2b72ba 4c81ee16 2981af19 6cb3f957 fd089b5e
532b2703 045b3f36 937c75eb 9c62b38c 20f4124a 06c0d87e ed1b603a a9f02576
fd006c7e cc6d1d84 65e9a178 becff6d3 14ba368b 804c993a b3433a63 a7f5aad7
578c915b 9c477a1c e2792319 ca6717ca 99fc475b 30bcce57 344cafa7 633ffb26
87637a41 348a4b52 9743f8f4 b7282b7f f573c1e8 acfce30e 5889a3da 820295cd
d212267c 4fa7b500 01a65080
2005-01-31 16:29:57: DEBUG: begin decryption.
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: IV was saved for next processing:
2005-01-31 16:29:57: DEBUG:
4fa7b500 01a65080
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: with key:
2005-01-31 16:29:57: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:57: DEBUG: decrypted payload by IV:
2005-01-31 16:29:57: DEBUG:
a9c4ad5d d5b949ec
2005-01-31 16:29:57: DEBUG: decrypted payload, but not trimed.
2005-01-31 16:29:57: DEBUG:
01000018 380ea746 6ae0ae2c 85ae1028 0de177dd 0d1641e4 0a00005c 00000001
00000001 02000028 01020401 0b02099a 0000001c 01030000 80010001 80020e10
80040002 80050002 80030002 00000028 01030401 0630e761 0000001c 01030000
80010001 80020e10 80040002 80050002 80030002 04000014 e96f29c8 6a300328
08b33126 f4cb4093 00000084 817cb76e 24ad3957 420f2480 3896017c 763c6b92
f22b6370 99afb7b9 00f322a8 d226f566 2eed3952 505c8c09 e6268dbe c6f2289a
eef9b5d1 cdd5fe02 edaeb785 9debe28e 7e18da13 9d8362f3 f0d1a6b0 3e8c2db8
75cf093a abd2aad9 0983bed7 8409dd12 e37dd22d 69589355 17e83f06 b7bd4e86
74130982 4515324b 7dfcd2d4 f0a28e03
2005-01-31 16:29:57: DEBUG: padding len=4
2005-01-31 16:29:57: DEBUG: skip to trim padding.
2005-01-31 16:29:57: DEBUG: decrypted.
2005-01-31 16:29:57: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 08102001 c4e55a01 0000012c 01000018
380ea746 6ae0ae2c 85ae1028 0de177dd 0d1641e4 0a00005c 00000001 00000001
02000028 01020401 0b02099a 0000001c 01030000 80010001 80020e10 80040002
80050002 80030002 00000028 01030401 0630e761 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 04000014 e96f29c8 6a300328 08b33126
f4cb4093 00000084 817cb76e 24ad3957 420f2480 3896017c 763c6b92 f22b6370
99afb7b9 00f322a8 d226f566 2eed3952 505c8c09 e6268dbe c6f2289a eef9b5d1
cdd5fe02 edaeb785 9debe28e 7e18da13 9d8362f3 f0d1a6b0 3e8c2db8 75cf093a
abd2aad9 0983bed7 8409dd12 e37dd22d 69589355 17e83f06 b7bd4e86 74130982
4515324b 7dfcd2d4 f0a28e03
2005-01-31 16:29:57: DEBUG: begin.
2005-01-31 16:29:57: DEBUG: seen nptype=8(hash)
2005-01-31 16:29:57: DEBUG: seen nptype=1(sa)
2005-01-31 16:29:57: DEBUG: seen nptype=10(nonce)
2005-01-31 16:29:57: DEBUG: seen nptype=4(ke)
2005-01-31 16:29:57: DEBUG: succeed.
2005-01-31 16:29:57: DEBUG: HASH allocated:hbuf->l=288 actual:tlen=260
2005-01-31 16:29:57: DEBUG: HASH(2) received:2005-01-31 16:29:57: DEBUG:
380ea746 6ae0ae2c 85ae1028 0de177dd 0d1641e4
2005-01-31 16:29:57: DEBUG: HASH with:
2005-01-31 16:29:57: DEBUG:
c4e55a01 e8df8a9c e76da0a2 8c0e0a3a 917629d1 0a00005c 00000001 00000001
02000028 01020401 0b02099a 0000001c 01030000 80010001 80020e10 80040002
80050002 80030002 00000028 01030401 0630e761 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 04000014 e96f29c8 6a300328 08b33126
f4cb4093 00000084 817cb76e 24ad3957 420f2480 3896017c 763c6b92 f22b6370
99afb7b9 00f322a8 d226f566 2eed3952 505c8c09 e6268dbe c6f2289a eef9b5d1
cdd5fe02 edaeb785 9debe28e 7e18da13 9d8362f3 f0d1a6b0 3e8c2db8 75cf093a
abd2aad9 0983bed7 8409dd12 e37dd22d 69589355 17e83f06 b7bd4e86 74130982
4515324b 7dfcd2d4
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: HASH computed:
2005-01-31 16:29:57: DEBUG:
380ea746 6ae0ae2c 85ae1028 0de177dd 0d1641e4
2005-01-31 16:29:57: DEBUG: total SA len=88
2005-01-31 16:29:57: DEBUG:
00000001 00000001 02000028 01020401 0755ad5d 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 00000028 01030401 08ab5d83 0000001c
01030000 80010001 80020e10 80040002 80050002 80030002
2005-01-31 16:29:57: DEBUG: begin.
2005-01-31 16:29:57: DEBUG: seen nptype=2(prop)
2005-01-31 16:29:57: DEBUG: seen nptype=2(prop)
2005-01-31 16:29:57: DEBUG: succeed.
2005-01-31 16:29:57: DEBUG: proposal #1 len=40
2005-01-31 16:29:57: DEBUG: begin.
2005-01-31 16:29:57: DEBUG: seen nptype=3(trns)
2005-01-31 16:29:57: DEBUG: succeed.
2005-01-31 16:29:57: DEBUG: transform #1 len=28
2005-01-31 16:29:57: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:57: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 16:29:57: DEBUG: life duration was in TLV.
2005-01-31 16:29:57: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 16:29:57: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 16:29:57: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: proposal #1 len=40
2005-01-31 16:29:57: DEBUG: begin.
2005-01-31 16:29:57: DEBUG: seen nptype=3(trns)
2005-01-31 16:29:57: DEBUG: succeed.
2005-01-31 16:29:57: DEBUG: transform #1 len=28
2005-01-31 16:29:57: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:57: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 16:29:57: DEBUG: life duration was in TLV.
2005-01-31 16:29:57: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 16:29:57: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 16:29:57: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: pair 1:
2005-01-31 16:29:57: DEBUG:  0x862c218: next=0x862b3e0 tnext=(nil)
2005-01-31 16:29:57: DEBUG:   0x862b3e0: next=(nil) tnext=(nil)
2005-01-31 16:29:57: DEBUG: proposal #1: 2 transform
2005-01-31 16:29:57: DEBUG: total SA len=88
2005-01-31 16:29:57: DEBUG:
00000001 00000001 02000028 01020401 0b02099a 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 00000028 01030401 0630e761 0000001c
01030000 80010001 80020e10 80040002 80050002 80030002
2005-01-31 16:29:57: DEBUG: begin.
2005-01-31 16:29:57: DEBUG: seen nptype=2(prop)
2005-01-31 16:29:57: DEBUG: seen nptype=2(prop)
2005-01-31 16:29:57: DEBUG: succeed.
2005-01-31 16:29:57: DEBUG: proposal #1 len=40
2005-01-31 16:29:57: DEBUG: begin.
2005-01-31 16:29:57: DEBUG: seen nptype=3(trns)
2005-01-31 16:29:57: DEBUG: succeed.
2005-01-31 16:29:57: DEBUG: transform #1 len=28
2005-01-31 16:29:57: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:57: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 16:29:57: DEBUG: life duration was in TLV.
2005-01-31 16:29:57: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 16:29:57: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 16:29:57: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: proposal #1 len=40
2005-01-31 16:29:57: DEBUG: begin.
2005-01-31 16:29:57: DEBUG: seen nptype=3(trns)
2005-01-31 16:29:57: DEBUG: succeed.
2005-01-31 16:29:57: DEBUG: transform #1 len=28
2005-01-31 16:29:57: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:57: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 16:29:57: DEBUG: life duration was in TLV.
2005-01-31 16:29:57: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 16:29:57: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 16:29:57: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 16:29:57: DEBUG: hmac(modp1024)
2005-01-31 16:29:57: DEBUG: pair 1:
2005-01-31 16:29:57: DEBUG:  0x862b450: next=0x862b5a0 tnext=(nil)
2005-01-31 16:29:57: DEBUG:   0x862b5a0: next=(nil) tnext=(nil)
2005-01-31 16:29:57: DEBUG: proposal #1: 2 transform
2005-01-31 16:29:57: DEBUG: begin compare proposals.
2005-01-31 16:29:57: DEBUG: pair[1]: 0x862b450
2005-01-31 16:29:57: DEBUG:  0x862b450: next=0x862b5a0 tnext=(nil)
2005-01-31 16:29:57: DEBUG:   0x862b5a0: next=(nil) tnext=(nil)
2005-01-31 16:29:57: DEBUG: prop#=1 prot-id=AH spi-size=4 #trns=1 trns#=1 trns-id=SHA
2005-01-31 16:29:57: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:57: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 16:29:57: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 16:29:57: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 16:29:57: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 16:29:57: DEBUG: prop#=1 prot-id=ESP spi-size=4 #trns=1 trns#=1 trns-id=3DES
2005-01-31 16:29:57: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 16:29:57: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 16:29:57: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 16:29:57: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 16:29:57: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 16:29:57: DEBUG: peer's single bundle:
2005-01-31 16:29:57: DEBUG:  (proto_id=AH spisize=4 spi=0b02099a spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 16:29:57: DEBUG:   (trns_id=SHA authtype=hmac-sha)
2005-01-31 16:29:57: DEBUG:  (proto_id=ESP spisize=4 spi=0630e761 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 16:29:57: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-sha)
2005-01-31 16:29:57: DEBUG: my single bundle:
2005-01-31 16:29:57: DEBUG:  (proto_id=AH spisize=4 spi=0755ad5d spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 16:29:57: DEBUG:   (trns_id=SHA authtype=hmac-sha)
2005-01-31 16:29:57: DEBUG:  (proto_id=ESP spisize=4 spi=08ab5d83 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 16:29:57: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-sha)
2005-01-31 16:29:57: DEBUG: matched
2005-01-31 16:29:57: DEBUG: ===
2005-01-31 16:29:57: DEBUG: HASH(3) generate
2005-01-31 16:29:57: DEBUG: HASH with:
2005-01-31 16:29:57: DEBUG:
00c4e55a 01e8df8a 9ce76da0 a28c0e0a 3a917629 d1e96f29 c86a3003 2808b331
26f4cb40 93
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: HASH computed:
2005-01-31 16:29:57: DEBUG:
8e1078c6 e27f5b7c 417232af 17ea670a 6209476f
2005-01-31 16:29:57: DEBUG: add payload of len 20, next type 0
2005-01-31 16:29:57: DEBUG: begin encryption.
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: pad length = 8
2005-01-31 16:29:57: DEBUG:
00000018 8e1078c6 e27f5b7c 417232af 17ea670a 6209476f e9e0ac88 a1fc8407
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: with key:
2005-01-31 16:29:57: DEBUG:
87950d10 c43b3cc4 5f8c71c1 0abde5ae 611d58e8 f3ac42fa
2005-01-31 16:29:57: DEBUG: encrypted payload by IV:
2005-01-31 16:29:57: DEBUG:
4fa7b500 01a65080
2005-01-31 16:29:57: DEBUG: save IV for next:
2005-01-31 16:29:57: DEBUG:
55362eb5 6175fc2f
2005-01-31 16:29:57: DEBUG: encrypted.
2005-01-31 16:29:57: DEBUG: 60 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 16:29:57: DEBUG: sockname 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 16:29:57: DEBUG: src4 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG: dst4 192.168.2.3[500]
2005-01-31 16:29:57: DEBUG: 1 times of 60 bytes message will be sent to 192.168.2.5[500]
2005-01-31 16:29:57: DEBUG:
6c9b6156 9b3a8f1e be23bf6c 739326c6 08102001 c4e55a01 0000003c de07f7dc
b98f7a0d a5dca431 f62059eb d2cf9943 2093a977 55362eb5 6175fc2f
2005-01-31 16:29:57: DEBUG: compute DH's shared.
2005-01-31 16:29:57: DEBUG:
9772727f d7c3077d cbc3a754 c01a6739 742445a1 ee69dd0e 401fcdca 387680c8
20d00459 1707ff44 f12623ad 01a23d78 eda3f7c2 c4194025 51dd8e3d 2c6dc226
d1e301b8 f646791e eceb475c 8bef4fa9 abb1fa9e 51240206 3a215462 6e8ccc48
5bedbcef 21a78faa d9619891 101d7132 ec61dac8 8ccd5ce4 093fbefa 04eb288c
2005-01-31 16:29:57: DEBUG: KEYMAT compute with
2005-01-31 16:29:57: DEBUG:
9772727f d7c3077d cbc3a754 c01a6739 742445a1 ee69dd0e 401fcdca 387680c8
20d00459 1707ff44 f12623ad 01a23d78 eda3f7c2 c4194025 51dd8e3d 2c6dc226
d1e301b8 f646791e eceb475c 8bef4fa9 abb1fa9e 51240206 3a215462 6e8ccc48
5bedbcef 21a78faa d9619891 101d7132 ec61dac8 8ccd5ce4 093fbefa 04eb288c
020755ad 5de8df8a 9ce76da0 a28c0e0a 3a917629 d1e96f29 c86a3003 2808b331
26f4cb40 93
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: encklen=0 authklen=0
2005-01-31 16:29:57: DEBUG: generating 480 bits of key (dupkeymat=3)
2005-01-31 16:29:57: DEBUG: generating K1...K3 for KEYMAT.
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG:
77ea373c ab2de6a9 e6579312 cf676dbf 21c8bb96 ebace6a6 b1166bf6 54e1cf78
1d21fda6 0ddc751d f03bdb9a 291fe5e4 ca2b43f3 4f325344 184a9142
2005-01-31 16:29:57: DEBUG: KEYMAT compute with
2005-01-31 16:29:57: DEBUG:
9772727f d7c3077d cbc3a754 c01a6739 742445a1 ee69dd0e 401fcdca 387680c8
20d00459 1707ff44 f12623ad 01a23d78 eda3f7c2 c4194025 51dd8e3d 2c6dc226
d1e301b8 f646791e eceb475c 8bef4fa9 abb1fa9e 51240206 3a215462 6e8ccc48
5bedbcef 21a78faa d9619891 101d7132 ec61dac8 8ccd5ce4 093fbefa 04eb288c
0308ab5d 83e8df8a 9ce76da0 a28c0e0a 3a917629 d1e96f29 c86a3003 2808b331
26f4cb40 93
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: encklen=192 authklen=160
2005-01-31 16:29:57: DEBUG: generating 640 bits of key (dupkeymat=4)
2005-01-31 16:29:57: DEBUG: generating K1...K4 for KEYMAT.
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG:
e0192628 3eaf975f b16ae699 19fe9e6c dccbf969 08579f54 4405a8f2 89edc409
67d3dd51 982e56c9 193ea791 d4f8ac73 ea9839b3 07999674 361ac816 a212efae
4cabfcb3 ee977bc6 dba0fc02 6b6e4448
2005-01-31 16:29:57: DEBUG: KEYMAT compute with
2005-01-31 16:29:57: DEBUG:
9772727f d7c3077d cbc3a754 c01a6739 742445a1 ee69dd0e 401fcdca 387680c8
20d00459 1707ff44 f12623ad 01a23d78 eda3f7c2 c4194025 51dd8e3d 2c6dc226
d1e301b8 f646791e eceb475c 8bef4fa9 abb1fa9e 51240206 3a215462 6e8ccc48
5bedbcef 21a78faa d9619891 101d7132 ec61dac8 8ccd5ce4 093fbefa 04eb288c
020b0209 9ae8df8a 9ce76da0 a28c0e0a 3a917629 d1e96f29 c86a3003 2808b331
26f4cb40 93
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: encklen=0 authklen=0
2005-01-31 16:29:57: DEBUG: generating 480 bits of key (dupkeymat=3)
2005-01-31 16:29:57: DEBUG: generating K1...K3 for KEYMAT.
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG:
cb630d9b 01c67612 34237d02 1b0282ce 678cb71e 6bf59eeb d6346e54 433db1cf
342b19a1 106ce650 80e76fb1 b717c3b2 fbde4a06 17dc6cb4 7e1bf87a
2005-01-31 16:29:57: DEBUG: KEYMAT compute with
2005-01-31 16:29:57: DEBUG:
9772727f d7c3077d cbc3a754 c01a6739 742445a1 ee69dd0e 401fcdca 387680c8
20d00459 1707ff44 f12623ad 01a23d78 eda3f7c2 c4194025 51dd8e3d 2c6dc226
d1e301b8 f646791e eceb475c 8bef4fa9 abb1fa9e 51240206 3a215462 6e8ccc48
5bedbcef 21a78faa d9619891 101d7132 ec61dac8 8ccd5ce4 093fbefa 04eb288c
030630e7 61e8df8a 9ce76da0 a28c0e0a 3a917629 d1e96f29 c86a3003 2808b331
26f4cb40 93
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: encryption(3des)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: encklen=192 authklen=160
2005-01-31 16:29:57: DEBUG: generating 640 bits of key (dupkeymat=4)
2005-01-31 16:29:57: DEBUG: generating K1...K4 for KEYMAT.
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG:
bba49802 a5c4b1f9 ea8acbca 89e71d58 0ccc98de 3c058484 72d3f62e 4610ea03
7c3b16b8 55510b1b 0ca537df e0628f09 deb7f29e 25c72ca6 47c2ec40 abe1120e
6757f6ba 8142b446 9ac07c04 138221c0
2005-01-31 16:29:57: DEBUG: KEYMAT computed.
2005-01-31 16:29:57: DEBUG: call pk_sendupdate
2005-01-31 16:29:57: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:57: DEBUG: call pfkey_send_update_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 2, p->sadb_msg_satype: 2, seq: 2)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 2, spi 1571640583)
2005-01-31 16:29:58: DEBUG: encryption(3des)
2005-01-31 16:29:58: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:58: DEBUG: call pfkey_send_update_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 2, p->sadb_msg_satype: 3, seq: 2)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 3, spi 2203953928)
2005-01-31 16:29:58: DEBUG: pfkey update sent.
2005-01-31 16:29:58: DEBUG: andi: pfkey.c, pk_sendadd: start
2005-01-31 16:29:58: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:58: DEBUG: call pfkey_send_add_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 3, p->sadb_msg_satype: 2, seq: 2)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 2, spi 2584281611)
2005-01-31 16:29:58: DEBUG: encryption(3des)
2005-01-31 16:29:58: DEBUG: hmac(hmac_sha1)
2005-01-31 16:29:58: DEBUG: call pfkey_send_add_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 3, p->sadb_msg_satype: 3, seq: 2)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 3, spi 1642541062)
2005-01-31 16:29:58: DEBUG: andi: pfkey.c, pk_sendadd: ende
2005-01-31 16:29:58: DEBUG: pfkey add sent.
2005-01-31 16:29:58: DEBUG: get pfkey UPDATE message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 2)
2005-01-31 16:29:58: DEBUG: andi: pfkey.c, pk_recvupdate: start
2005-01-31 16:29:58: DEBUG: andi: in pfkey.c, pk_recvupdate: msg->sadb_msg_seq 2, msg->sadb_msg_type: UPDATE
2005-01-31 16:29:58: DEBUG: pfkey UPDATE succeeded: AH/Transport 192.168.2.3->192.168.2.5 spi=123055453(0x755ad5d)
2005-01-31 16:29:58: INFO: IPsec-SA established: AH/Transport 192.168.2.3->192.168.2.5 spi=123055453(0x755ad5d)
2005-01-31 16:29:58: DEBUG: get pfkey UPDATE message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 2)
2005-01-31 16:29:58: DEBUG: andi: pfkey.c, pk_recvupdate: start
2005-01-31 16:29:58: DEBUG: andi: in pfkey.c, pk_recvupdate: msg->sadb_msg_seq 2, msg->sadb_msg_type: UPDATE
2005-01-31 16:29:58: DEBUG: pfkey UPDATE succeeded: ESP/Transport 192.168.2.3->192.168.2.5 spi=145448323(0x8ab5d83)
2005-01-31 16:29:58: INFO: IPsec-SA established: ESP/Transport 192.168.2.3->192.168.2.5 spi=145448323(0x8ab5d83)
2005-01-31 16:29:58: DEBUG: andi: pfkey.c, pk_recvupdate: ende
2005-01-31 16:29:58: DEBUG: ===
2005-01-31 16:29:58: DEBUG: get pfkey ADD message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 3)
2005-01-31 16:29:58: DEBUG: andi: in pfkey.c, pk_recvadd: msg->sadb_msg_seq 2, msg->sadb_msg_type: ADD
2005-01-31 16:29:58: INFO: IPsec-SA established: AH/Transport 192.168.2.5->192.168.2.3 spi=184682906(0xb02099a)
2005-01-31 16:29:58: DEBUG: ===
2005-01-31 16:29:58: DEBUG: get pfkey ADD message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 3)
2005-01-31 16:29:58: DEBUG: andi: in pfkey.c, pk_recvadd: msg->sadb_msg_seq 2, msg->sadb_msg_type: ADD
2005-01-31 16:29:58: INFO: IPsec-SA established: ESP/Transport 192.168.2.5->192.168.2.3 spi=103868257(0x630e761)
2005-01-31 16:29:58: DEBUG: ===



--Boundary-00=_gFl/Bi96WSERiIA--
