From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.4 0/16] e1000: driver update (fwd)
Date: Wed, 27 Apr 2005 11:00:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271100260.17397-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

1. Added enhanced functionality to the loopback diags to wrap the descrip=
tor rings.
2. Fix msec-delay definition in e1000_osdep.h to use msleep
3. MSI support for PCI-e adapters
4. Enable polling before enabling interrupts -- avoids (in NAPI mode) ent=
ering the ISR and returning without doing any work because polling is not=
 enabled.
[romieu@fr.zoriel.com]

5. Fix kernel panic with 82541 LOM when using a 100M cable
6. Delay clean-up of last Tx packet to fix pre-mature writeback issue of =
Tx descriptors only when TSO is enabled
7. Dump information on Tx ring when 'NETDEV: Watchdog' condition is reach=
ed
8. Fix computation of netdev stats from controller stats counters
9. e1000 stops working after resume, call pci_enable_device after pci_res=
tore_state - Modified Andrew Morton's patch
10. Implement 82546 errata 10 --=A0 first Tx descriptor cannot have more =
than 2015 byte of data in it or it could hang the transmitter.

11. Removed redundant statement in e1000_clean_tx_irq
12. Modified e1000_clean:: exit poll if no Tx and work_done =3D=3D 0
13. 82573 specific code & packet split code
14. Fix Packet Buffer Allocation logic for 82547_rev_2 controller
15. Adjust flow control watermarks for Jumbo Frames
16. Driver version, white space, comments, device id & other
