From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH v2 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Tue, 27 May 2008 22:26:04 -0700
Message-ID: <adaskw3q9sj.fsf@cisco.com>
References: <20080519102843.12355.832.stgit@localhost.localdomain>
	<20080519103529.12355.82570.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080519103529.12355.82570.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Mon, 19 May 2008 16:05:29 +0530")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > +ssize_t vnic_create_primary(struct device *dev,
 > +			    struct device_attribute *dev_attr, const char *buf,
 > +			    size_t count)

 > +ssize_t vnic_create_secondary(struct device *dev,
 > +			      struct device_attribute *dev_attr,
 > +			      const char *buf, size_t count)

 > +ssize_t vnic_delete(struct device *dev, struct device_attribute *dev_attr,
 > +		    const char *buf, size_t count)

These are all only referenced from a sysfs attribute defined in the same
file, so they can be made static (and don't need extern declarations in
a header file).
