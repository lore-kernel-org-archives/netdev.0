From: pgs@synerway.com
Subject: Re: need some help on a backport of r8169
Date: Mon, 12 Mar 2007 17:51:30 +0100
Message-ID: <20070312165130.GA10394@venus.synerway.com>
References: <20070226170941.GA17587@venus.synerway.com> <20070226234831.GA12830@electric-eye.fr.zoreil.com> <20070227110243.GA15657@venus.synerway.com> <20070227212400.GA12760@electric-eye.fr.zoreil.com> <20070228160133.GA8014@venus.synerway.com> <20070228230807.GB23772@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.synerway.com ([84.14.10.249]:48966 "EHLO
	stargate.synerway.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030686AbXCLQvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 12:51:35 -0400
Received: from kamino.synerway.com (kamino [172.16.1.21])
	by stargate.synerway.com (Postfix) with ESMTP id D995775C16E
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 18:27:48 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20070228230807.GB23772@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Fran=E7ois,

I've been a little long, but it's done, I've tested the last patch you
sent me.
It was the patch of the 28 Feb 2007.
The result is the same as the previous. It has the time to send some
packets but quickly blocks.

Here are the ifcofnig + ethtool infos :

eth0      Link encap:Ethernet  HWaddr 00:16:EC:8F:2F:AF =20
          inet addr:172.16.10.159  Bcast:172.16.255.255  Mask:255.255.0=
=2E0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:808 errors:0 dropped:0 overruns:0 frame:0
          TX packets:26 errors:0 dropped:43 overruns:0 carrier:0
          collisions:0 txqueuelen:1000=20
          RX bytes:64571 (63.0 Kb)  TX bytes:3092 (3.0 Kb)
          Interrupt:10 Base address:0xe000=20

Offset	Value
--------	-----
00	0x00
01	0x16
02	0xec
03	0x8f
04	0x2f
05	0xaf
06	0x00
07	0x00
08	0xff
09	0xff
10	0xff
11	0xff
12	0xff
13	0xff
14	0xff
15	0xff
16	0x00
17	0x01
18	0x38
19	0xf7
20	0xc4
21	0x01
22	0x38
23	0xf7
24	0x00
25	0x00
26	0x00
27	0x00
28	0x00
29	0x00
30	0x00
31	0x00
32	0x00
33	0x20
34	0x00
35	0x0e
36	0x00
37	0x00
38	0x00
39	0x00
40	0x00
41	0x01
42	0x38
43	0xf7
44	0xc4
45	0x01
46	0x38
47	0xf7
48	0x00
49	0x00
50	0x00
51	0x00
52	0x00
53	0x00
54	0x00
55	0x0c
56	0x00
57	0x00
58	0x00
59	0x00
60	0x3f
61	0x80
62	0x00
63	0x00
64	0x00
65	0x06
66	0x00
67	0x3b
68	0x0e
69	0xe6
70	0x00
71	0x00
72	0x13
73	0x20
74	0x56
75	0xee
76	0x00
77	0x00
78	0x00
79	0x00
80	0x00
81	0x05
82	0x0f
83	0x30
84	0x20
85	0x00
86	0x01
87	0x00
88	0x00
89	0x00
90	0x00
91	0x00
92	0x00
93	0x00
94	0x00
95	0x00
96	0x00
97	0x10
98	0x00
99	0x80
100	0xc4
101	0x01
102	0x38
103	0xf7
104	0xdc
105	0x52
106	0x00
107	0x00
108	0x0a
109	0x02
110	0x01
111	0x00
112	0x00
113	0x00
114	0x00
115	0x00
116	0x00
117	0x00
118	0x00
119	0x00
120	0x00
121	0x00
122	0xff
123	0xff
124	0x00
125	0x00
126	0x00
127	0x00
128	0x93
129	0x1b
130	0x01
131	0x80
132	0xc4
133	0x01
134	0x38
135	0xf7
136	0xc4
137	0x01
138	0x38
139	0xf7
140	0xc4
141	0x01
142	0x38
143	0xf7
144	0xc4
145	0x01
146	0x38
147	0xf7
148	0xc4
149	0x01
150	0x38
151	0xf7
152	0xc4
153	0x01
154	0x38
155	0xf7
156	0xc4
157	0x01
158	0x38
159	0xf7
160	0xc4
161	0x01
162	0x38
163	0xf7
164	0xc4
165	0x01
166	0x38
167	0xf7
168	0xc4
169	0x01
170	0x38
171	0xf7
172	0xc4
173	0x01
174	0x38
175	0xf7
176	0xc4
177	0x01
178	0x38
179	0xf7
180	0xc4
181	0x01
182	0x38
183	0xf7
184	0xc4
185	0x01
186	0x38
187	0xf7
188	0xc4
189	0x01
190	0x38
191	0xf7
192	0xc4
193	0x01
194	0x38
195	0xf7
196	0xc4
197	0x01
198	0x38
199	0xf7
200	0xc4
201	0x01
202	0x38
203	0xf7
204	0xc4
205	0x01
206	0x00
207	0x00
208	0x00
209	0x00
210	0x00
211	0x00
212	0x00
213	0x00
214	0x00
215	0x00
216	0x00
217	0x00
218	0xff
219	0x3f
220	0x00
221	0x00
222	0x00
223	0x00
224	0xa9
225	0x20
226	0x51
227	0x51
228	0x00
229	0xe0
230	0xa9
231	0x13
232	0x00
233	0x00
234	0x00
235	0x00
236	0x3f
237	0x00
238	0x00
239	0x00
240	0x00
241	0x00
242	0x00
243	0x00
244	0x00
245	0x00
246	0x00
247	0x00
248	0x00
249	0x00
250	0x00
251	0x00
252	0x00
253	0x00
254	0x00
255	0x00



You asked me to remind you to check if there is a PCI-Exepress version
of the RTL8169, I do it.

And I'll soon send you the url of my patch against the r1000 driver.

One more question, does anyone know if the 2.6.21 kernel is gonna come
out soon?


Pascal



=46rancois Romieu a =E9crit, le Thu 01 Mar 2007 =E0 12:08:07AM :
> pgs@synerway.com <pgs@synerway.com> :
> [...]
> > The result is as follows :
> > I boot my new kernel : the r8169 driver is automatically loaded and
> > find the network card and gives me an eth0.
> > I do a ifconfig, eth0 is up, with an IP and RX and TX are not 0.
>=20
> Interesting.
>=20
> > The problem comes here, I do a ping and it seems to have just the t=
ime
> > to make the DNS resolution but not further. When I do a new ifconfi=
g,
> > the TX dropped is not 0 anymore. Then I can turn up and down my
> > interface, I won't be able to ping anything.
>=20
> Ok, almost perfect for a first try. :o)
>=20
> If you can issue 'ifconfig' and do an ethtool dump of the registers a=
t
> the interesting points in time, it could surely help.
>=20
> [...]
> > Ah... poor me who thought that the RTL8168 was just like the RTL816=
9 with
> > a pci express interface... It seems that a PCI-Express RTL8169 also
> > exist right?
>=20
> Remind me to check it later.
>=20
> [...]
> > Do you think my problem is the one you mentionned above, without th=
e
> > experimental patches?
>=20
> It is possible. I should review the diffs too.
>=20
> Once you have logged the ifconfig/ethtool dump, you can try the serie
> or the patch at:
>=20
> http://www.fr.zoreil.com/people/francois/backport/r8169/20070228-00
>=20
> Btw:
>=20
> [...dmesg dump...]
> > Enabling fast FPU save and restore... done.
> > Enabling unmasked SIMD FPU exception support... done.
> > Checking 'hlt' instruction... OK.
> > ACPI: setting ELCR to 0200 (from 0c08)
> > NET: Registered protocol family 16
> > PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=3D2
> > PCI: Using MMCONFIG
>=20
> Please disable MMCONFIG.
>=20
> If you have any PCI latency option in your bios, set it to 64.
>=20
> --=20
> Ueimor
