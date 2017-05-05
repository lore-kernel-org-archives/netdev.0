From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Fri, 5 May 2017 14:04:38 +0800
Message-ID: <201705051329.3hqBfDhC%fengguang.wu@intel.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Cc: alsa-devel@alsa-project.org,
 Heikki Krogerus <heikki.krogerus@linux.intel.com>,
 Liam Girdwood <lgirdwood@gmail.com>, linux-pci@vger.kernel.org,
 Amir Goldstein <amir73il@gmail.com>,
 Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Benjamin Tissoires <benjamin.tissoires@redhat.com>,
 Joerg Roedel <joro@8bytes.org>, linux-acpi@vger.kernel.org,
 tpmdd-devel@lists.sourceforge.net, Ben Skeggs <bskeggs@redhat.com>,
 nouveau@lists.freedesktop.org, linux-mmc@vger.kernel.org,
 Zhang Rui <rui.zhang@intel.com>, Borislav Petkov <bp@suse.de>,
 Yisen Zhuang <yisen.zhuang@huawei.com>,
 Mathias Nyman <mathias.nyman@intel.com>, intel-gfx@lists.freedesktop.org,
 linux-input@vger.kernel.org, Mark Brown <broonie@kernel.org>,
 Bjorn Helgaas <bhelgaas@google.com>, Dan Williams <dan.j.williams@intel.com>,
 Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andy,

[auto build test ERROR on next-20170503]
[cannot apply to pm/linux-next linus/master linux/master v4.9-rc8 v4.9-rc7 v4.9-rc6 v4.11]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Andy-Shevchenko/ACPI-Switch-to-use-generic-UUID-API/20170505-134225
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   In file included from init/main.c:29:0:
>> include/linux/acpi.h:744:16: error: unknown type name 'uuid_le'
             const uuid_le *uuid,
                   ^~~~~~~

vim +/uuid_le +744 include/linux/acpi.h

   738						    const struct device_driver *drv)
   739	{
   740		return false;
   741	}
   742	
   743	static inline union acpi_object *acpi_evaluate_dsm(acpi_handle handle,
 > 744							   const uuid_le *uuid,
   745							   int rev, int func,
   746							   union acpi_object *argv4)
   747	{

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--G4iJoqBmSsgzjUCe
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwtZ2Z4
IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlz
dHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==

--G4iJoqBmSsgzjUCe--
