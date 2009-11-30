From: Bill Nottingham <notting@redhat.com>
Subject: Re: [PROPOSAL]: Support Alternate Network Device Naming Schemes
Date: Mon, 30 Nov 2009 13:34:37 -0500
Message-ID: <20091130183435.GC15213@nostromo.devel.redhat.com>
References: <20091127094257.GA24624@mock.linuxdev.us.dell.com>
Reply-To: Discussion of Development and Customization of the Red Hat Linux
	Installer <anaconda-devel-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shyam_iyer@dell.com, matt_domsch@dell.com,
	jordan_hargrave@dell.com, charles_rose@dell.com
To: Discussion of Development and Customization of the Red Hat Linux Installer
	<anaconda-devel-list@redhat.com>
Return-path: <anaconda-devel-list-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20091127094257.GA24624@mock.linuxdev.us.dell.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/anaconda-devel-list>,
	<mailto:anaconda-devel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/anaconda-devel-list>
List-Post: <mailto:anaconda-devel-list@redhat.com>
List-Help: <mailto:anaconda-devel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/anaconda-devel-list>,
	<mailto:anaconda-devel-list-request@redhat.com?subject=subscribe>
Sender: anaconda-devel-list-bounces@redhat.com
Errors-To: anaconda-devel-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Narendra K (Narendra_K@dell.com) said: 
> Installers as of now allow the discovered network interfaces to be configured. This solution proposes to provide an option for the users to either retain the default naming convention that the kernel now has, i.e ethN names or rename the network interfaces based on the chassis label, MAC addresses, Driver name and any other naming convention. Here is how the modified network configuration wizard would look during the os installation process - 
> 
> 
> ---------- Network Configuration ------------------------
> 
> Default [ ] |  SMBIOS Names [x]     |  Driver Names []  | MAC Names []
> -----------------------------------------------------------------------
>  eth0       | Addin_NIC_1           | ice0              |            
> -----------------------------------------------------------------------
>  eth1       | Embedded_NIC_1        | bce0              |             
> -----------------------------------------------------------------------
>  eth2       | Embedded_NIC_2        | bce1              |             
> -----------------------------------------------------------------------
>  eth3       | Embedded_NIC_3        | bce2              |            
> -----------------------------------------------------------------------
>  eth4       | Embedded_NIC_4        | bce3              |            
> -----------------------------------------------------------------------
> 
>                                                         ------------
>                                                         | Next     |
>                                                         ------------
> 
> [ ice0 - Intel Controller 0, bce0 - Broadcom Controller 0 ] 
> 
> 1. In addition to the default ethN names the user can check against the available naming conventions and the wizard would show the names the interfaces will be renamed to.
> 2. The moment the user hits the Next button all interfaces are renamed as per the Naming convention they have selected.
> 3. Any further network communication would  be using the new names.
> 4. Ifconfig would show names like "Embedded_NIC_1" and not eth0 etc.

That's a horrible interface to show the user when a large portion of
them do not care at all. (Also, not sure why netdev@vger cares about the
implementation details of OS installers.)

Bill
