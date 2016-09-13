From: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 02/11] Add RoCE driver framework
Date: Tue, 13 Sep 2016 09:22:04 +0000
Message-ID: <DM3PR1101MB1181337A65B7CEFC1A30F353E2FE0@DM3PR1101MB1181.namprd11.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <516b98c7-477a-4890-0d92-529dc32f2c4e-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks for your comments.
See my replies in line with [Ram].



-----Original Message-----
From: Mark Bloch [mailto:markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org]=20
Sent: Monday, September 12, 2016 9:44 PM
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; David Miller <=
davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Ariel Elior <Ariel.Elior@qlogic.c=
om>; Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Rajesh Borundia <rajesh.=
borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev <netdev-u79uwXL29TZNg+MwTxZMZA@public.gmane.org=
l.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework


Hi Ram,

Just a few thoughts=20

On 12/09/2016 19:07, Ram Amrani wrote:
> Adds a skeletal implementation of the qed* RoCE driver - basically the=20
> ability to communicate with the qede driver and receive notifications=20
> from it regarding various init/exit events.
>=20
> Signed-off-by: Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/infiniband/Kconfig                   |   2 +
>  drivers/infiniband/hw/Makefile               |   1 +
>  drivers/infiniband/hw/qedr/Kconfig           |   7 +
>  drivers/infiniband/hw/qedr/Makefile          |   3 +
>  drivers/infiniband/hw/qedr/main.c            | 293 +++++++++++++++++++++=
++++
>  drivers/infiniband/hw/qedr/qedr.h            |  60 ++++++
>  drivers/net/ethernet/qlogic/qede/Makefile    |   1 +
>  drivers/net/ethernet/qlogic/qede/qede.h      |   9 +
>  drivers/net/ethernet/qlogic/qede/qede_main.c |  35 ++- =20
> drivers/net/ethernet/qlogic/qede/qede_roce.c | 309 ++++++++++++++++++++++=
+++++
>  include/linux/qed/qed_if.h                   |   3 +-
>  include/linux/qed/qede_roce.h                |  88 ++++++++
>  include/uapi/linux/pci_regs.h                |   3 +
>  13 files changed, 803 insertions(+), 11 deletions(-)  create mode=20
> 100644 drivers/infiniband/hw/qedr/Kconfig
>  create mode 100644 drivers/infiniband/hw/qedr/Makefile
>  create mode 100644 drivers/infiniband/hw/qedr/main.c  create mode=20
> 100644 drivers/infiniband/hw/qedr/qedr.h  create mode 100644=20
> drivers/net/ethernet/qlogic/qede/qede_roce.c
>  create mode 100644 include/linux/qed/qede_roce.h

[SNIP]

> +
> +MODULE_DESCRIPTION("QLogic 40G/100G ROCE Driver");=20
> +MODULE_AUTHOR("QLogic Corporation"); MODULE_LICENSE("Dual BSD/GPL");=20
> +MODULE_VERSION(QEDR_MODULE_VERSION);
> +
> +uint debug;
> +module_param(debug, uint, 0);
> +MODULE_PARM_DESC(debug, "Default debug msglevel");

Why are you adding this as a module parameter?=20
[Ram] Yuval commented on this in a previous e-mail


> +static LIST_HEAD(qedr_dev_list);
> +static DEFINE_SPINLOCK(qedr_devlist_lock);
> +

You already have a qedr_dev_list mutex in the qede_roce.c file, why do you =
need this spinlock as well?

 [Ram] qedr_devlist_lock - a static (local) list of qedr devices maintained=
 by qedr, protected by spinlock. Not in used in the current patches.
qedr_dev_list_lock (with '_') - a static (local) list of qedr devices maint=
ained by qede, protected by mutex.
We'll consider removing the first as it is currently not used and/or rename=
 them to be more distinct.



> +void qedr_ib_dispatch_event(struct qedr_dev *dev, u8 port_num,
> +			    enum ib_event_type type)
> +{
> +	struct ib_event ibev;
> +
> +	ibev.device =3D &dev->ibdev;
> +	ibev.element.port_num =3D port_num;
> +	ibev.event =3D type;
> +
> +	ib_dispatch_event(&ibev);
> +}
> +
> +static enum rdma_link_layer qedr_link_layer(struct ib_device *device,
> +					    u8 port_num)
> +{
> +	return IB_LINK_LAYER_ETHERNET;
> +}
> +
> +static int qedr_register_device(struct qedr_dev *dev) {
> +	strlcpy(dev->ibdev.name, "qedr%d", IB_DEVICE_NAME_MAX);
> +
> +	memcpy(dev->ibdev.node_desc, QEDR_NODE_DESC, sizeof(QEDR_NODE_DESC));
> +	dev->ibdev.owner =3D THIS_MODULE;
> +
> +	dev->ibdev.get_link_layer =3D qedr_link_layer;
> +
> +	return 0;
> +}
> +
> +/* QEDR sysfs interface */
> +static ssize_t show_rev(struct device *device, struct device_attribute *=
attr,
> +			char *buf)
> +{
> +	struct qedr_dev *dev =3D dev_get_drvdata(device);
> +
> +	return scnprintf(buf, PAGE_SIZE, "0x%x\n", dev->pdev->vendor); }
> +
> +static ssize_t show_fw_ver(struct device *device, struct device_attribut=
e *attr,
> +			   char *buf)
> +{
> +	return scnprintf(buf, PAGE_SIZE, "%s\n", "FW_VER_TO_ADD"); }

Ira Weiny has added a generic way to expose firmware versions in the rdma s=
tack, can you have please have a look at c73428230d98d1352bcc69cd8306c292a8=
5e1e42 and see how he converted the mlx5_ib module to use it.
[Ram] This way is replaced to be the same as you describe in patch 0004. I'=
ll if I can move it to this patch to avoid confusion.

> +static ssize_t show_hca_type(struct device *device,
> +			     struct device_attribute *attr, char *buf) {
> +	return scnprintf(buf, PAGE_SIZE, "%s\n", "HCA_TYPE_TO_SET"); }
> +
> +static DEVICE_ATTR(hw_rev, S_IRUGO, show_rev, NULL); static=20
> +DEVICE_ATTR(fw_ver, S_IRUGO, show_fw_ver, NULL); static=20
> +DEVICE_ATTR(hca_type, S_IRUGO, show_hca_type, NULL);
> +
> +static struct device_attribute *qedr_attributes[] =3D {
> +	&dev_attr_hw_rev,
> +	&dev_attr_fw_ver,
> +	&dev_attr_hca_type
> +};
> +
> +static void qedr_remove_sysfiles(struct qedr_dev *dev) {
> +	int i;
> +
> +	for (i =3D 0; i < ARRAY_SIZE(qedr_attributes); i++)
> +		device_remove_file(&dev->ibdev.dev, qedr_attributes[i]); }
> +
> +void qedr_config_debug(uint debug, u32 *p_dp_module, u8 *p_dp_level)=20
> +{
> +	*p_dp_level =3D 0;
> +	*p_dp_module =3D 0;
> +
> +	if (debug & QED_LOG_VERBOSE_MASK) {
> +		*p_dp_level =3D QED_LEVEL_VERBOSE;
> +		*p_dp_module =3D (debug & 0x3FFFFFFF);
> +	} else if (debug & QED_LOG_INFO_MASK) {
> +		*p_dp_level =3D QED_LEVEL_INFO;
> +	} else if (debug & QED_LOG_NOTICE_MASK) {
> +		*p_dp_level =3D QED_LEVEL_NOTICE;
> +	}
> +}
> +
> +static void qedr_pci_set_atomic(struct qedr_dev *dev, struct pci_dev=20
> +*pdev) {
> +	struct pci_dev *bridge;
> +	u32 val;
> +
> +	dev->atomic_cap =3D IB_ATOMIC_NONE;
> +
> +	bridge =3D pdev->bus->self;
> +	if (!bridge)
> +		return;
> +
> +	/* Check whether we are connected directly or via a switch */
> +	while (bridge && bridge->bus->parent) {
> +		DP_NOTICE(dev,
> +			  "Device is not connected directly to root. bridge->bus->number=3D%d=
 primary=3D%d\n",
> +			  bridge->bus->number, bridge->bus->primary);
> +		/* Need to check Atomic Op Routing Supported all the way to
> +		 * root complex.
> +		 */
> +		pcie_capability_read_dword(bridge, PCI_EXP_DEVCAP2, &val);
> +		if (!(val & PCI_EXP_DEVCAP2_ATOMIC_ROUTE)) {
> +			pcie_capability_clear_word(pdev,
> +						   PCI_EXP_DEVCTL2,
> +						   PCI_EXP_DEVCTL2_ATOMIC_REQ);
> +			return;
> +		}
> +		bridge =3D bridge->bus->parent->self;
> +	}
> +	bridge =3D pdev->bus->self;
> +
> +	/* according to bridge capability */
> +	pcie_capability_read_dword(bridge, PCI_EXP_DEVCAP2, &val);
> +	if (val & PCI_EXP_DEVCAP2_ATOMIC_COMP64) {
> +		pcie_capability_set_word(pdev, PCI_EXP_DEVCTL2,
> +					 PCI_EXP_DEVCTL2_ATOMIC_REQ);
> +		dev->atomic_cap =3D IB_ATOMIC_GLOB;
> +	} else {
> +		pcie_capability_clear_word(pdev, PCI_EXP_DEVCTL2,
> +					   PCI_EXP_DEVCTL2_ATOMIC_REQ);
> +	}
> +}
> +
> +static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *p=
dev,
> +				 struct net_device *ndev)
> +{
> +	struct qedr_dev *dev;
> +	int rc =3D 0, i;
> +
> +	dev =3D (struct qedr_dev *)ib_alloc_device(sizeof(*dev));
> +	if (!dev) {
> +		pr_err("Unable to allocate ib device\n");
> +		return NULL;
> +	}
> +
> +	qedr_config_debug(debug, &dev->dp_module, &dev->dp_level);
> +	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr add device called\n");
> +
> +	dev->pdev =3D pdev;
> +	dev->ndev =3D ndev;
> +	dev->cdev =3D cdev;
> +
> +	qedr_pci_set_atomic(dev, pdev);
> +
> +	rc =3D qedr_register_device(dev);
> +	if (rc) {
> +		DP_ERR(dev, "Unable to allocate register device\n");
> +		goto init_err;
> +	}
> +
> +	for (i =3D 0; i < ARRAY_SIZE(qedr_attributes); i++)
> +		if (device_create_file(&dev->ibdev.dev, qedr_attributes[i]))
> +			goto init_err;
> +
> +	spin_lock(&qedr_devlist_lock);
> +	list_add_tail_rcu(&dev->entry, &qedr_dev_list);
> +	spin_unlock(&qedr_devlist_lock);
> +
> +	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr driver loaded successfully\n");
> +	return dev;
> +
> +init_err:
> +	ib_dealloc_device(&dev->ibdev);
> +	DP_ERR(dev, "qedr driver load failed rc=3D%d\n", rc);
> +
> +	return NULL;
> +}
> +
> +static void qedr_remove(struct qedr_dev *dev) {
> +	/* First unregister with stack to stop all the active traffic
> +	 * of the registered clients.
> +	 */
> +	qedr_remove_sysfiles(dev);
> +
> +	spin_lock(&qedr_devlist_lock);
> +	list_del_rcu(&dev->entry);
> +	spin_unlock(&qedr_devlist_lock);
> +
> +	ib_dealloc_device(&dev->ibdev);
> +}
> +
> +static int qedr_close(struct qedr_dev *dev) {
> +	qedr_ib_dispatch_event(dev, 1, IB_EVENT_PORT_ERR);
> +

Why are you sending port number hard-coded as 1?

[Ram] Our implementation always uses one port. Here's the ibv_devinfo outpu=
t for example:
hca_id:	qedr0
	transport:			InfiniBand (0)
	fw_ver:				8.10.10.0
	...
	phys_port_cnt:			1
		port:	1
			state:			PORT_ACTIVE (4)
			...
			link_layer:		Ethernet

hca_id:	qedr1
	transport:			InfiniBand (0)
	fw_ver:				8.10.10.0
	...
	phys_port_cnt:			1
		port:	1
			state:			PORT_ACTIVE (4)
			...
			link_layer:		Ethernet

Mark
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
