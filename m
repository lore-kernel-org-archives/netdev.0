From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 16:50:51 -0600
Message-ID: <200501071650.56423.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3698898.e4CMkgbPaj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart3698898.e4CMkgbPaj
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 07 January 2005 04:28 pm, Jesse Brandeburg wrote:
> On Fri, 7 Jan 2005, Jeremy M. Guthrie wrote:
> > I just updated the Intel Drivers to the latest on source-forge(5.6.10.1=
).
> >  I now see lower CPU usage but I am still dropping.
> >
> > During a 60 second window the machine received 5,110,164 packets and
> > dropped 20461 or roughly 0.4% packet loss.
>
> NAPI will cause a very busy stack to force the network card to drop the
> data instead of the stack.  This is supposed to be a good thing because
> the hardware will be forced to drop the packet (hopefully) instead of
> interrupt rate thrashing your machine right when it needs the cpu to do
> other stuff.  This is supposed to be the saving grace of NAPI.
Makes sense.

> So, not to distract from the conversation, but in the interest (my
> interest :-) ) of tuning your E1000, can you please send the output of
> ethtool -S ethX for each interface?  This will help us figure out if there
> is anything to tune in the driver (like number of rx buffers, etc)
ethtool -S eth2
NIC statistics:
     rx_packets: 0
     tx_packets: 314550698
     rx_bytes: 0
     tx_bytes: 4290523139
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 0
     rx_csum_offload_good: 0
     rx_csum_offload_errors: 0
ethtool -S eth3
NIC statistics:
     rx_packets: 719847127
     tx_packets: 5
     rx_bytes: 1880301945
     tx_bytes: 398
     rx_errors: 3368295
     tx_errors: 0
     rx_dropped: 1478044
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 1890251
     rx_missed_errors: 1890251
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 379837423993
     rx_csum_offload_good: 672891990
     rx_csum_offload_errors: 178666



> Thanks,
>   Jesse

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart3698898.e4CMkgbPaj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3xJQqtjaBHGZBeURAnqnAJ4u5AYcsqHQbD3fiintw+AZ9jKleACgkXpd
s7D1duGwiCPoROghnbOC0PY=
=MiFq
-----END PGP SIGNATURE-----

--nextPart3698898.e4CMkgbPaj--
