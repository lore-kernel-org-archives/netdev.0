From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: network interface cards native vlans support in linux kernel?
Date: Wed, 9 Jul 2003 18:33:46 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C93B9@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Andrius Kasparavicius" <andrius@andrius.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Do you mean "native" as in hardware acceleration offloading?
If that's the case than the 8021q vlan module handshakes with the device driver to check for support and that's it. No need to do any settings on the device. In case there is no offloading support, the vlan module will take care of all stripping/inserting of the vlan tag into place.
On the other hand, if the device cannot handle 1504 byte packets, it defines itself as "vlan challenged" and you can't use vlan on it at all.


-- 
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |


> -----Original Message-----
> From: Andrius Kasparavicius [mailto:andrius@andrius.org]
> Sent: Wednesday, July 09, 2003 6:20 PM
> To: netdev@oss.sgi.com
> Subject: network interface cards native vlans support in linux kernel?
> 
> 
> 
> hello, as far as i know, currently there is no native vlan support in
> network device drivers. I mean, always need patching MTU.. 
> add 4 bytes..
> :-(
> 
> is there any problems to include full vlans support?
> 
> 
> Andrius
> 
> 
