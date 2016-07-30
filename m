From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 08/10] drivers: net: xgene: Poll link status via
 GPIO
Date: Sat, 30 Jul 2016 12:32:35 +0800
Message-ID: <201607301242.96Hv3p6V%fengguang.wu@intel.com>
References: <1469838843-19943-9-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, linux@armlinux.org.uk,
	Iyappan Subramanian <isubramanian@apm.com>,
	Quan Nguyen <qnguyen@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8955 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbcG3Edx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2016 00:33:53 -0400
Content-Disposition: inline
In-Reply-To: <1469838843-19943-9-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Iyappan-Subramanian/Fix-warning-and-issues/20160730-083713
config: xtensa-allmodconfig (attached as .config)
compiler: xtensa-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=xtensa 

All error/warnings (new ones prefixed by >>):

   drivers/gpio/gpio-xgene-sb.c: In function 'xgene_gpio_sb_irq_set_type':
>> drivers/gpio/gpio-xgene-sb.c:111:3: error: implicit declaration of function 'irq_chip_set_type_parent' [-Werror=implicit-function-declaration]
      return irq_chip_set_type_parent(d, IRQ_TYPE_EDGE_RISING);
      ^
   drivers/gpio/gpio-xgene-sb.c: At top level:
>> drivers/gpio/gpio-xgene-sb.c:118:13: error: 'irq_chip_eoi_parent' undeclared here (not in a function)
     .irq_eoi = irq_chip_eoi_parent,
                ^
>> drivers/gpio/gpio-xgene-sb.c:119:20: error: 'irq_chip_mask_parent' undeclared here (not in a function)
     .irq_mask       = irq_chip_mask_parent,
                       ^
>> drivers/gpio/gpio-xgene-sb.c:120:20: error: 'irq_chip_unmask_parent' undeclared here (not in a function)
     .irq_unmask     = irq_chip_unmask_parent,
                       ^
   drivers/gpio/gpio-xgene-sb.c: In function 'xgene_gpio_sb_domain_alloc':
>> drivers/gpio/gpio-xgene-sb.c:198:3: error: implicit declaration of function 'irq_domain_set_hwirq_and_chip' [-Werror=implicit-function-declaration]
      irq_domain_set_hwirq_and_chip(domain, virq + i, hwirq + i,
      ^
>> drivers/gpio/gpio-xgene-sb.c:201:31: error: 'struct irq_domain' has no member named 'parent'
     parent_fwspec.fwnode = domain->parent->fwnode;
                                  ^
>> drivers/gpio/gpio-xgene-sb.c:215:2: error: implicit declaration of function 'irq_domain_alloc_irqs_parent' [-Werror=implicit-function-declaration]
     return irq_domain_alloc_irqs_parent(domain, virq, nr_irqs,
     ^
   drivers/gpio/gpio-xgene-sb.c: At top level:
>> drivers/gpio/gpio-xgene-sb.c:220:2: error: unknown field 'translate' specified in initializer
     .translate      = xgene_gpio_sb_domain_translate,
     ^
>> drivers/gpio/gpio-xgene-sb.c:220:2: warning: initialization from incompatible pointer type
   drivers/gpio/gpio-xgene-sb.c:220:2: warning: (near initialization for 'xgene_gpio_sb_domain_ops.match')
>> drivers/gpio/gpio-xgene-sb.c:221:2: error: unknown field 'alloc' specified in initializer
     .alloc          = xgene_gpio_sb_domain_alloc,
     ^
   drivers/gpio/gpio-xgene-sb.c:221:2: warning: initialization from incompatible pointer type
   drivers/gpio/gpio-xgene-sb.c:221:2: warning: (near initialization for 'xgene_gpio_sb_domain_ops.select')
>> drivers/gpio/gpio-xgene-sb.c:222:2: error: unknown field 'free' specified in initializer
     .free           = irq_domain_free_irqs_common,
     ^
>> drivers/gpio/gpio-xgene-sb.c:222:20: error: 'irq_domain_free_irqs_common' undeclared here (not in a function)
     .free           = irq_domain_free_irqs_common,
                       ^
>> drivers/gpio/gpio-xgene-sb.c:223:2: error: unknown field 'activate' specified in initializer
     .activate = xgene_gpio_sb_domain_activate,
     ^
   drivers/gpio/gpio-xgene-sb.c:223:2: warning: initialization from incompatible pointer type
   drivers/gpio/gpio-xgene-sb.c:223:2: warning: (near initialization for 'xgene_gpio_sb_domain_ops.unmap')
>> drivers/gpio/gpio-xgene-sb.c:224:2: error: unknown field 'deactivate' specified in initializer
     .deactivate = xgene_gpio_sb_domain_deactivate,
     ^
   drivers/gpio/gpio-xgene-sb.c:224:2: warning: initialization from incompatible pointer type
   drivers/gpio/gpio-xgene-sb.c:224:2: warning: (near initialization for 'xgene_gpio_sb_domain_ops.xlate')
   drivers/gpio/gpio-xgene-sb.c: In function 'xgene_gpio_sb_probe':
>> drivers/gpio/gpio-xgene-sb.c:293:2: error: implicit declaration of function 'irq_domain_create_hierarchy' [-Werror=implicit-function-declaration]
     priv->irq_domain = irq_domain_create_hierarchy(parent_domain,
     ^
>> drivers/gpio/gpio-xgene-sb.c:293:19: warning: assignment makes pointer from integer without a cast
     priv->irq_domain = irq_domain_create_hierarchy(parent_domain,
                      ^
   cc1: some warnings being treated as errors

vim +/irq_chip_set_type_parent +111 drivers/gpio/gpio-xgene-sb.c

1013fc417 Quan Nguyen        2016-02-17  105  			gpio * 2, 1);
1013fc417 Quan Nguyen        2016-02-17  106  	xgene_gpio_set_bit(&priv->gc, priv->regs + MPA_GPIO_INT_LVL,
1013fc417 Quan Nguyen        2016-02-17  107  			d->hwirq, lvl_type);
1013fc417 Quan Nguyen        2016-02-17  108  
1013fc417 Quan Nguyen        2016-02-17  109  	/* Propagate IRQ type setting to parent */
1013fc417 Quan Nguyen        2016-02-17  110  	if (type & IRQ_TYPE_EDGE_BOTH)
1013fc417 Quan Nguyen        2016-02-17 @111  		return irq_chip_set_type_parent(d, IRQ_TYPE_EDGE_RISING);
1013fc417 Quan Nguyen        2016-02-17  112  	else
1013fc417 Quan Nguyen        2016-02-17  113  		return irq_chip_set_type_parent(d, IRQ_TYPE_LEVEL_HIGH);
1013fc417 Quan Nguyen        2016-02-17  114  }
1013fc417 Quan Nguyen        2016-02-17  115  
1013fc417 Quan Nguyen        2016-02-17  116  static struct irq_chip xgene_gpio_sb_irq_chip = {
1013fc417 Quan Nguyen        2016-02-17  117  	.name           = "sbgpio",
1013fc417 Quan Nguyen        2016-02-17 @118  	.irq_eoi	= irq_chip_eoi_parent,
1013fc417 Quan Nguyen        2016-02-17 @119  	.irq_mask       = irq_chip_mask_parent,
1013fc417 Quan Nguyen        2016-02-17 @120  	.irq_unmask     = irq_chip_unmask_parent,
1013fc417 Quan Nguyen        2016-02-17  121  	.irq_set_type   = xgene_gpio_sb_irq_set_type,
1013fc417 Quan Nguyen        2016-02-17  122  };
b2b35e108 Y Vo               2015-01-16  123  
1013fc417 Quan Nguyen        2016-02-17  124  static int xgene_gpio_sb_to_irq(struct gpio_chip *gc, u32 gpio)
1013fc417 Quan Nguyen        2016-02-17  125  {
1013fc417 Quan Nguyen        2016-02-17  126  	struct xgene_gpio_sb *priv = gpiochip_get_data(gc);
1013fc417 Quan Nguyen        2016-02-17  127  	struct irq_fwspec fwspec;
b2b35e108 Y Vo               2015-01-16  128  
1013fc417 Quan Nguyen        2016-02-17  129  	if ((gpio < priv->irq_start) ||
1013fc417 Quan Nguyen        2016-02-17  130  			(gpio > HWIRQ_TO_GPIO(priv, priv->nirq)))
b2b35e108 Y Vo               2015-01-16  131  		return -ENXIO;
1013fc417 Quan Nguyen        2016-02-17  132  
1013fc417 Quan Nguyen        2016-02-17  133  	if (gc->parent->of_node)
1013fc417 Quan Nguyen        2016-02-17  134  		fwspec.fwnode = of_node_to_fwnode(gc->parent->of_node);
1013fc417 Quan Nguyen        2016-02-17  135  	else
1013fc417 Quan Nguyen        2016-02-17  136  		fwspec.fwnode = gc->parent->fwnode;
1013fc417 Quan Nguyen        2016-02-17  137  	fwspec.param_count = 2;
1013fc417 Quan Nguyen        2016-02-17  138  	fwspec.param[0] = GPIO_TO_HWIRQ(priv, gpio);
1013fc417 Quan Nguyen        2016-02-17  139  	fwspec.param[1] = IRQ_TYPE_NONE;
1013fc417 Quan Nguyen        2016-02-17  140  	return irq_create_fwspec_mapping(&fwspec);
1013fc417 Quan Nguyen        2016-02-17  141  }
1013fc417 Quan Nguyen        2016-02-17  142  
1013fc417 Quan Nguyen        2016-02-17  143  static void xgene_gpio_sb_domain_activate(struct irq_domain *d,
1013fc417 Quan Nguyen        2016-02-17  144  		struct irq_data *irq_data)
1013fc417 Quan Nguyen        2016-02-17  145  {
1013fc417 Quan Nguyen        2016-02-17  146  	struct xgene_gpio_sb *priv = d->host_data;
1013fc417 Quan Nguyen        2016-02-17  147  	u32 gpio = HWIRQ_TO_GPIO(priv, irq_data->hwirq);
1013fc417 Quan Nguyen        2016-02-17  148  
1013fc417 Quan Nguyen        2016-02-17  149  	if (gpiochip_lock_as_irq(&priv->gc, gpio)) {
1013fc417 Quan Nguyen        2016-02-17  150  		dev_err(priv->gc.parent,
1013fc417 Quan Nguyen        2016-02-17  151  		"Unable to configure XGene GPIO standby pin %d as IRQ\n",
1013fc417 Quan Nguyen        2016-02-17  152  				gpio);
1013fc417 Quan Nguyen        2016-02-17  153  		return;
1013fc417 Quan Nguyen        2016-02-17  154  	}
1013fc417 Quan Nguyen        2016-02-17  155  
1013fc417 Quan Nguyen        2016-02-17  156  	xgene_gpio_set_bit(&priv->gc, priv->regs + MPA_GPIO_SEL_LO,
1013fc417 Quan Nguyen        2016-02-17  157  			gpio * 2, 1);
1013fc417 Quan Nguyen        2016-02-17  158  }
1013fc417 Quan Nguyen        2016-02-17  159  
1013fc417 Quan Nguyen        2016-02-17  160  static void xgene_gpio_sb_domain_deactivate(struct irq_domain *d,
1013fc417 Quan Nguyen        2016-02-17  161  		struct irq_data *irq_data)
1013fc417 Quan Nguyen        2016-02-17  162  {
1013fc417 Quan Nguyen        2016-02-17  163  	struct xgene_gpio_sb *priv = d->host_data;
1013fc417 Quan Nguyen        2016-02-17  164  	u32 gpio = HWIRQ_TO_GPIO(priv, irq_data->hwirq);
1013fc417 Quan Nguyen        2016-02-17  165  
1013fc417 Quan Nguyen        2016-02-17  166  	gpiochip_unlock_as_irq(&priv->gc, gpio);
1013fc417 Quan Nguyen        2016-02-17  167  	xgene_gpio_set_bit(&priv->gc, priv->regs + MPA_GPIO_SEL_LO,
1013fc417 Quan Nguyen        2016-02-17  168  			gpio * 2, 0);
1013fc417 Quan Nguyen        2016-02-17  169  }
1013fc417 Quan Nguyen        2016-02-17  170  
1013fc417 Quan Nguyen        2016-02-17  171  static int xgene_gpio_sb_domain_translate(struct irq_domain *d,
1013fc417 Quan Nguyen        2016-02-17  172  		struct irq_fwspec *fwspec,
1013fc417 Quan Nguyen        2016-02-17  173  		unsigned long *hwirq,
1013fc417 Quan Nguyen        2016-02-17  174  		unsigned int *type)
1013fc417 Quan Nguyen        2016-02-17  175  {
1013fc417 Quan Nguyen        2016-02-17  176  	struct xgene_gpio_sb *priv = d->host_data;
1013fc417 Quan Nguyen        2016-02-17  177  
1013fc417 Quan Nguyen        2016-02-17  178  	if ((fwspec->param_count != 2) ||
1013fc417 Quan Nguyen        2016-02-17  179  		(fwspec->param[0] >= priv->nirq))
1013fc417 Quan Nguyen        2016-02-17  180  		return -EINVAL;
1013fc417 Quan Nguyen        2016-02-17  181  	*hwirq = fwspec->param[0];
1013fc417 Quan Nguyen        2016-02-17  182  	*type = fwspec->param[1];
1013fc417 Quan Nguyen        2016-02-17  183  	return 0;
b2b35e108 Y Vo               2015-01-16  184  }
b2b35e108 Y Vo               2015-01-16  185  
1013fc417 Quan Nguyen        2016-02-17  186  static int xgene_gpio_sb_domain_alloc(struct irq_domain *domain,
1013fc417 Quan Nguyen        2016-02-17  187  					unsigned int virq,
1013fc417 Quan Nguyen        2016-02-17  188  					unsigned int nr_irqs, void *data)
1013fc417 Quan Nguyen        2016-02-17  189  {
1013fc417 Quan Nguyen        2016-02-17  190  	struct irq_fwspec *fwspec = data;
1013fc417 Quan Nguyen        2016-02-17  191  	struct irq_fwspec parent_fwspec;
1013fc417 Quan Nguyen        2016-02-17  192  	struct xgene_gpio_sb *priv = domain->host_data;
1013fc417 Quan Nguyen        2016-02-17  193  	irq_hw_number_t hwirq;
1013fc417 Quan Nguyen        2016-02-17  194  	unsigned int i;
1013fc417 Quan Nguyen        2016-02-17  195  
1013fc417 Quan Nguyen        2016-02-17  196  	hwirq = fwspec->param[0];
1013fc417 Quan Nguyen        2016-02-17  197  	for (i = 0; i < nr_irqs; i++)
1013fc417 Quan Nguyen        2016-02-17 @198  		irq_domain_set_hwirq_and_chip(domain, virq + i, hwirq + i,
1013fc417 Quan Nguyen        2016-02-17  199  				&xgene_gpio_sb_irq_chip, priv);
1013fc417 Quan Nguyen        2016-02-17  200  
1013fc417 Quan Nguyen        2016-02-17 @201  	parent_fwspec.fwnode = domain->parent->fwnode;
1013fc417 Quan Nguyen        2016-02-17  202  	if (is_of_node(parent_fwspec.fwnode)) {
1013fc417 Quan Nguyen        2016-02-17  203  		parent_fwspec.param_count = 3;
1013fc417 Quan Nguyen        2016-02-17  204  		parent_fwspec.param[0] = 0;/* SPI */
1013fc417 Quan Nguyen        2016-02-17  205  		/* Skip SGIs and PPIs*/
1013fc417 Quan Nguyen        2016-02-17  206  		parent_fwspec.param[1] = hwirq + priv->parent_irq_base - 32;
1013fc417 Quan Nguyen        2016-02-17  207  		parent_fwspec.param[2] = fwspec->param[1];
1013fc417 Quan Nguyen        2016-02-17  208  	} else if (is_fwnode_irqchip(parent_fwspec.fwnode)) {
1013fc417 Quan Nguyen        2016-02-17  209  		parent_fwspec.param_count = 2;
1013fc417 Quan Nguyen        2016-02-17  210  		parent_fwspec.param[0] = hwirq + priv->parent_irq_base;
1013fc417 Quan Nguyen        2016-02-17  211  		parent_fwspec.param[1] = fwspec->param[1];
1013fc417 Quan Nguyen        2016-02-17  212  	} else
1013fc417 Quan Nguyen        2016-02-17  213  		return -EINVAL;
1013fc417 Quan Nguyen        2016-02-17  214  
1013fc417 Quan Nguyen        2016-02-17 @215  	return irq_domain_alloc_irqs_parent(domain, virq, nr_irqs,
1013fc417 Quan Nguyen        2016-02-17  216  			&parent_fwspec);
1013fc417 Quan Nguyen        2016-02-17  217  }
1013fc417 Quan Nguyen        2016-02-17  218  
1013fc417 Quan Nguyen        2016-02-17  219  static const struct irq_domain_ops xgene_gpio_sb_domain_ops = {
1013fc417 Quan Nguyen        2016-02-17 @220  	.translate      = xgene_gpio_sb_domain_translate,
1013fc417 Quan Nguyen        2016-02-17 @221  	.alloc          = xgene_gpio_sb_domain_alloc,
c6cc75fec Axel Lin           2016-03-17 @222  	.free           = irq_domain_free_irqs_common,
1013fc417 Quan Nguyen        2016-02-17 @223  	.activate	= xgene_gpio_sb_domain_activate,
1013fc417 Quan Nguyen        2016-02-17 @224  	.deactivate	= xgene_gpio_sb_domain_deactivate,
1013fc417 Quan Nguyen        2016-02-17  225  };
1013fc417 Quan Nguyen        2016-02-17  226  
b2b35e108 Y Vo               2015-01-16  227  static int xgene_gpio_sb_probe(struct platform_device *pdev)
b2b35e108 Y Vo               2015-01-16  228  {
b2b35e108 Y Vo               2015-01-16  229  	struct xgene_gpio_sb *priv;
67ebb742b Andrzej Hajda      2016-02-23  230  	int ret;
b2b35e108 Y Vo               2015-01-16  231  	struct resource *res;
b2b35e108 Y Vo               2015-01-16  232  	void __iomem *regs;
1013fc417 Quan Nguyen        2016-02-17  233  	struct irq_domain *parent_domain = NULL;
1013fc417 Quan Nguyen        2016-02-17  234  	struct fwnode_handle *fwnode;
1013fc417 Quan Nguyen        2016-02-17  235  	u32 val32;
b2b35e108 Y Vo               2015-01-16  236  
b2b35e108 Y Vo               2015-01-16  237  	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
b2b35e108 Y Vo               2015-01-16  238  	if (!priv)
b2b35e108 Y Vo               2015-01-16  239  		return -ENOMEM;
b2b35e108 Y Vo               2015-01-16  240  
b2b35e108 Y Vo               2015-01-16  241  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
b2b35e108 Y Vo               2015-01-16  242  	regs = devm_ioremap_resource(&pdev->dev, res);
33c07b467 Vladimir Zapolskiy 2015-03-29  243  	if (IS_ERR(regs))
b2b35e108 Y Vo               2015-01-16  244  		return PTR_ERR(regs);
b2b35e108 Y Vo               2015-01-16  245  
1013fc417 Quan Nguyen        2016-02-17  246  	priv->regs = regs;
1013fc417 Quan Nguyen        2016-02-17  247  
1013fc417 Quan Nguyen        2016-02-17  248  	ret = platform_get_irq(pdev, 0);
1013fc417 Quan Nguyen        2016-02-17  249  	if (ret > 0) {
1013fc417 Quan Nguyen        2016-02-17  250  		priv->parent_irq_base = irq_get_irq_data(ret)->hwirq;
1013fc417 Quan Nguyen        2016-02-17  251  		parent_domain = irq_get_irq_data(ret)->domain;
1013fc417 Quan Nguyen        2016-02-17  252  	}
1013fc417 Quan Nguyen        2016-02-17  253  	if (!parent_domain) {
1013fc417 Quan Nguyen        2016-02-17  254  		dev_err(&pdev->dev, "unable to obtain parent domain\n");
1013fc417 Quan Nguyen        2016-02-17  255  		return -ENODEV;
1013fc417 Quan Nguyen        2016-02-17  256  	}
1013fc417 Quan Nguyen        2016-02-17  257  
0f4630f37 Linus Walleij      2015-12-04  258  	ret = bgpio_init(&priv->gc, &pdev->dev, 4,
b2b35e108 Y Vo               2015-01-16  259  			regs + MPA_GPIO_IN_ADDR,
b2b35e108 Y Vo               2015-01-16  260  			regs + MPA_GPIO_OUT_ADDR, NULL,
b2b35e108 Y Vo               2015-01-16  261  			regs + MPA_GPIO_OE_ADDR, NULL, 0);
b2b35e108 Y Vo               2015-01-16  262          if (ret)
b2b35e108 Y Vo               2015-01-16  263                  return ret;
b2b35e108 Y Vo               2015-01-16  264  
1013fc417 Quan Nguyen        2016-02-17  265  	priv->gc.to_irq = xgene_gpio_sb_to_irq;
b2b35e108 Y Vo               2015-01-16  266  
1013fc417 Quan Nguyen        2016-02-17  267  	/* Retrieve start irq pin, use default if property not found */
1013fc417 Quan Nguyen        2016-02-17  268  	priv->irq_start = XGENE_DFLT_IRQ_START_PIN;
1013fc417 Quan Nguyen        2016-02-17  269  	if (!device_property_read_u32(&pdev->dev,
1013fc417 Quan Nguyen        2016-02-17  270  					XGENE_IRQ_START_PROPERTY, &val32))
1013fc417 Quan Nguyen        2016-02-17  271  		priv->irq_start = val32;
b2b35e108 Y Vo               2015-01-16  272  
1013fc417 Quan Nguyen        2016-02-17  273  	/* Retrieve number irqs, use default if property not found */
1013fc417 Quan Nguyen        2016-02-17  274  	priv->nirq = XGENE_DFLT_MAX_NIRQ;
1013fc417 Quan Nguyen        2016-02-17  275  	if (!device_property_read_u32(&pdev->dev, XGENE_NIRQ_PROPERTY, &val32))
1013fc417 Quan Nguyen        2016-02-17  276  		priv->nirq = val32;
b2b35e108 Y Vo               2015-01-16  277  
1013fc417 Quan Nguyen        2016-02-17  278  	/* Retrieve number gpio, use default if property not found */
1013fc417 Quan Nguyen        2016-02-17  279  	priv->gc.ngpio = XGENE_DFLT_MAX_NGPIO;
1013fc417 Quan Nguyen        2016-02-17  280  	if (!device_property_read_u32(&pdev->dev, XGENE_NGPIO_PROPERTY, &val32))
1013fc417 Quan Nguyen        2016-02-17  281  		priv->gc.ngpio = val32;
1013fc417 Quan Nguyen        2016-02-17  282  
1013fc417 Quan Nguyen        2016-02-17  283  	dev_info(&pdev->dev, "Support %d gpios, %d irqs start from pin %d\n",
1013fc417 Quan Nguyen        2016-02-17  284  			priv->gc.ngpio, priv->nirq, priv->irq_start);
b2b35e108 Y Vo               2015-01-16  285  
b2b35e108 Y Vo               2015-01-16  286  	platform_set_drvdata(pdev, priv);
b2b35e108 Y Vo               2015-01-16  287  
1013fc417 Quan Nguyen        2016-02-17  288  	if (pdev->dev.of_node)
1013fc417 Quan Nguyen        2016-02-17  289  		fwnode = of_node_to_fwnode(pdev->dev.of_node);
b2b35e108 Y Vo               2015-01-16  290  	else
1013fc417 Quan Nguyen        2016-02-17  291  		fwnode = pdev->dev.fwnode;
1013fc417 Quan Nguyen        2016-02-17  292  
1013fc417 Quan Nguyen        2016-02-17 @293  	priv->irq_domain = irq_domain_create_hierarchy(parent_domain,
1013fc417 Quan Nguyen        2016-02-17  294  					0, priv->nirq, fwnode,
1013fc417 Quan Nguyen        2016-02-17  295  					&xgene_gpio_sb_domain_ops, priv);
1013fc417 Quan Nguyen        2016-02-17  296  	if (!priv->irq_domain)

:::::: The code at line 111 was first introduced by commit
:::::: 1013fc417cc15ead7c3a9091a47617f357db71a4 gpio: xgene: Enable X-Gene standby GPIO as interrupt controller

:::::: TO: Quan Nguyen <qnguyen@apm.com>
:::::: CC: Linus Walleij <linus.walleij@linaro.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--BOKacYhQ+x31HxR3
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
9o2x2zWOO5FXMceXTDbGT+f/bbucarjNAgA=

--BOKacYhQ+x31HxR3--
