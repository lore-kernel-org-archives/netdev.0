From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 2/3] cxgb4: use
	module_long_probe_init()
Date: Fri, 15 Aug 2014 15:12:05 +0800
Message-ID: <20140815071205.GA6293@kroah.com>
References: <525DB349B3FB5444AE057A887CB2A8D85A0977@nice.asicdesigners.com>
 <53ECE709.5030008@chelsio.com>
 <20140814195321.GO21930@wotan.suse.de>
 <20140815001458.GT21930@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 "tiwai@suse.de" <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
 Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
 "MPT-FusionLinux.pdl@avagotech.com" <MPT-FusionLinux.pdl@avagotech.com>,
 Tim Gardner <tim.gardner@canonical.com>, Benjamin Poirier <bpoirier@suse.de>,
 Santosh Rastapur <santosh@chelsio.com>, Casey Leedom <leedom@chelsio.com>,
 Hariprasad S <hariprasad@chelsio.com>,
 Pierre Fersing <pierre-fersing@pierref.org>, Anish Bhatt <anish@chelsio.com>,
 Oleg Nesterov <oleg@redhat.com>,
 Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
 systemd-devel@lists.freedesktop.org,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 "netdev@vger.kernel.org"
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20140815001458.GT21930@wotan.suse.de>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: systemd-devel-bounces@lists.freedesktop.org
Sender: "systemd-devel" <systemd-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2014 at 02:14:58AM +0200, Luis R. Rodriguez wrote:
> This driver also uses module_pci_driver() so a module_long_probe_driver()
> and respective module_long_probe_pci_driver() would need to be considered
> if but easily implemented (sent to Alex to test).

No, don't create bus-only versions of the "long probe" function, just
unwrap the module_pci_driver() logic and use the module_long_probe()
call, we want it to be "obvious" that something is odd here and needs to
be fixed someday.

thanks,

greg k-h
