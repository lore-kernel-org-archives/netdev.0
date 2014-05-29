From: abdoulaye berthe <berthe.ab@gmail.com>
Subject: [PATCH] gpio: removes all usage of gpiochip_remove retval
Date: Thu, 29 May 2014 23:54:52 +0200
Message-ID: <1401400492-26175-1-git-send-email-berthe.ab@gmail.com>
Cc: abdoulaye berthe <berthe.ab@gmail.com>
To: linus.walleij@linaro.org, gnurou@gmail.com, m@bues.ch,
	linux-gpio@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	patches@opensource.wolfsonmicro.com, linux-input@vger.kernel.org,
	linux-leds@vger.kernel.org, linux-media@vger.kernel.org,
	linux-samsungsoc@vger.kernel.org, spear-devel@list.st.com,
	platform-driver-x86@vger.kernel.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org
Return-path: <linux-leds-owner@vger.kernel.org>
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: abdoulaye berthe <berthe.ab@gmail.com>
---
 arch/arm/common/scoop.c                        | 10 ++--------
 arch/mips/txx9/generic/setup.c                 |  4 ++--
 arch/powerpc/platforms/83xx/mcu_mpc8349emitx.c |  3 ++-
 arch/sh/boards/mach-x3proto/gpio.c             |  6 ++----
 drivers/bcma/driver_gpio.c                     |  3 ++-
 drivers/gpio/gpio-74x164.c                     |  8 +++-----
 drivers/gpio/gpio-adnp.c                       |  9 +--------
 drivers/gpio/gpio-adp5520.c                    |  8 +-------
 drivers/gpio/gpio-adp5588.c                    |  6 +-----
 drivers/gpio/gpio-amd8111.c                    |  3 +--
 drivers/gpio/gpio-arizona.c                    |  3 ++-
 drivers/gpio/gpio-cs5535.c                     |  8 +-------
 drivers/gpio/gpio-da9052.c                     |  3 ++-
 drivers/gpio/gpio-da9055.c                     |  3 ++-
 drivers/gpio/gpio-dwapb.c                      |  2 +-
 drivers/gpio/gpio-em.c                         |  5 +----
 drivers/gpio/gpio-f7188x.c                     | 18 ++----------------
 drivers/gpio/gpio-generic.c                    |  3 ++-
 drivers/gpio/gpio-grgpio.c                     |  4 +---
 drivers/gpio/gpio-ich.c                        |  9 +--------
 drivers/gpio/gpio-it8761e.c                    |  6 +-----
 drivers/gpio/gpio-janz-ttl.c                   |  8 +-------
 drivers/gpio/gpio-kempld.c                     |  3 ++-
 drivers/gpio/gpio-lp3943.c                     |  3 ++-
 drivers/gpio/gpio-lynxpoint.c                  |  5 +----
 drivers/gpio/gpio-max730x.c                    | 12 ++++--------
 drivers/gpio/gpio-max732x.c                    |  7 +------
 drivers/gpio/gpio-mc33880.c                    | 11 +++--------
 drivers/gpio/gpio-mc9s08dz60.c                 |  3 ++-
 drivers/gpio/gpio-mcp23s08.c                   | 26 +++++++-------------------
 drivers/gpio/gpio-ml-ioh.c                     |  8 ++------
 drivers/gpio/gpio-msm-v2.c                     |  5 +----
 drivers/gpio/gpio-mxc.c                        |  2 +-
 drivers/gpio/gpio-octeon.c                     |  3 ++-
 drivers/gpio/gpio-palmas.c                     |  3 ++-
 drivers/gpio/gpio-pca953x.c                    |  7 +------
 drivers/gpio/gpio-pcf857x.c                    |  4 +---
 drivers/gpio/gpio-pch.c                        | 10 ++--------
 drivers/gpio/gpio-rc5t583.c                    |  3 ++-
 drivers/gpio/gpio-rcar.c                       |  5 +----
 drivers/gpio/gpio-rdc321x.c                    |  7 ++-----
 drivers/gpio/gpio-sch.c                        | 16 +++-------------
 drivers/gpio/gpio-sch311x.c                    |  6 ++----
 drivers/gpio/gpio-sodaville.c                  |  4 +---
 drivers/gpio/gpio-stmpe.c                      |  8 +-------
 drivers/gpio/gpio-sx150x.c                     |  7 ++-----
 drivers/gpio/gpio-syscon.c                     |  3 ++-
 drivers/gpio/gpio-tb10x.c                      |  5 +----
 drivers/gpio/gpio-tc3589x.c                    |  8 +-------
 drivers/gpio/gpio-timberdale.c                 |  5 +----
 drivers/gpio/gpio-tps6586x.c                   |  3 ++-
 drivers/gpio/gpio-tps65910.c                   |  3 ++-
 drivers/gpio/gpio-tps65912.c                   |  3 ++-
 drivers/gpio/gpio-ts5500.c                     |  6 +++---
 drivers/gpio/gpio-twl4030.c                    |  4 +---
 drivers/gpio/gpio-twl6040.c                    |  3 ++-
 drivers/gpio/gpio-ucb1400.c                    |  2 +-
 drivers/gpio/gpio-viperboard.c                 | 10 +++-------
 drivers/gpio/gpio-vx855.c                      |  3 +--
 drivers/gpio/gpio-wm831x.c                     |  3 ++-
 drivers/gpio/gpio-wm8350.c                     |  3 ++-
 drivers/gpio/gpio-wm8994.c                     |  3 ++-
 drivers/hid/hid-cp2112.c                       |  6 ++----
 drivers/input/keyboard/adp5588-keys.c          |  4 +---
 drivers/input/keyboard/adp5589-keys.c          |  4 +---
 drivers/input/touchscreen/ad7879.c             | 10 +++-------
 drivers/leds/leds-pca9532.c                    | 10 ++--------
 drivers/leds/leds-tca6507.c                    |  7 ++-----
 drivers/media/dvb-frontends/cxd2820r_core.c    | 10 +++-------
 drivers/mfd/asic3.c                            |  3 ++-
 drivers/mfd/htc-i2cpld.c                       |  8 +-------
 drivers/mfd/sm501.c                            | 17 +++--------------
 drivers/mfd/tc6393xb.c                         | 13 ++++---------
 drivers/mfd/ucb1x00-core.c                     |  8 ++------
 drivers/pinctrl/pinctrl-abx500.c               | 15 +++------------
 drivers/pinctrl/pinctrl-adi2.c                 |  9 ++++-----
 drivers/pinctrl/pinctrl-as3722.c               | 11 ++---------
 drivers/pinctrl/pinctrl-baytrail.c             |  5 +----
 drivers/pinctrl/pinctrl-coh901.c               | 10 ++--------
 drivers/pinctrl/pinctrl-exynos5440.c           |  6 +-----
 drivers/pinctrl/pinctrl-msm.c                  | 11 ++---------
 drivers/pinctrl/pinctrl-nomadik.c              |  2 +-
 drivers/pinctrl/pinctrl-rockchip.c             | 16 ++++------------
 drivers/pinctrl/pinctrl-samsung.c              | 14 ++++----------
 drivers/pinctrl/pinctrl-sunxi.c                |  3 +--
 drivers/pinctrl/sh-pfc/gpio.c                  |  9 +++------
 drivers/pinctrl/spear/pinctrl-plgpio.c         |  3 +--
 drivers/pinctrl/vt8500/pinctrl-wmt.c           |  9 ++-------
 drivers/platform/x86/intel_pmic_gpio.c         |  3 +--
 drivers/ssb/driver_gpio.c                      |  3 ++-
 drivers/staging/vme/devices/vme_pio2_gpio.c    |  4 +---
 drivers/tty/serial/max310x.c                   | 10 ++++------
 drivers/video/fbdev/via/via-gpio.c             | 10 +++-------
 sound/soc/codecs/wm5100.c                      |  5 +----
 sound/soc/codecs/wm8903.c                      |  6 +-----
 sound/soc/codecs/wm8962.c                      |  5 +----
 sound/soc/codecs/wm8996.c                      |  6 +-----
 97 files changed, 182 insertions(+), 460 deletions(-)

diff --git a/arch/arm/common/scoop.c b/arch/arm/common/scoop.c
index 6ef146e..5881c9c 100644
--- a/arch/arm/common/scoop.c
+++ b/arch/arm/common/scoop.c
@@ -244,18 +244,12 @@ err_ioremap:
 static int scoop_remove(struct platform_device *pdev)
 {
 	struct scoop_dev *sdev = platform_get_drvdata(pdev);
-	int ret;
 
 	if (!sdev)
 		return -EINVAL;
 
-	if (sdev->gpio.base != -1) {
-		ret = gpiochip_remove(&sdev->gpio);
-		if (ret) {
-			dev_err(&pdev->dev, "Can't remove gpio chip: %d\n", ret);
-			return ret;
-		}
-	}
+	if (sdev->gpio.base != -1)
+		gpiochip_remove(&sdev->gpio);
 
 	platform_set_drvdata(pdev, NULL);
 	iounmap(sdev->base);
diff --git a/arch/mips/txx9/generic/setup.c b/arch/mips/txx9/generic/setup.c
index 2b0b83c..b7e8d47 100644
--- a/arch/mips/txx9/generic/setup.c
+++ b/arch/mips/txx9/generic/setup.c
@@ -789,11 +789,11 @@ void __init txx9_iocled_init(unsigned long baseaddr,
 	if (platform_device_add(pdev))
 		goto out_pdev;
 	return;
+
 out_pdev:
 	platform_device_put(pdev);
 out_gpio:
-	if (gpiochip_remove(&iocled->chip))
-		return;
+	gpiochip_remove(&iocled->chip);
 out_unmap:
 	iounmap(iocled->mmioaddr);
 out_free:
diff --git a/arch/powerpc/platforms/83xx/mcu_mpc8349emitx.c b/arch/powerpc/platforms/83xx/mcu_mpc8349emitx.c
index e238b6a..7399702 100644
--- a/arch/powerpc/platforms/83xx/mcu_mpc8349emitx.c
+++ b/arch/powerpc/platforms/83xx/mcu_mpc8349emitx.c
@@ -141,7 +141,8 @@ static int mcu_gpiochip_add(struct mcu *mcu)
 
 static int mcu_gpiochip_remove(struct mcu *mcu)
 {
-	return gpiochip_remove(&mcu->gc);
+	gpiochip_remove(&mcu->gc);
+	return 0;
 }
 
 static int mcu_probe(struct i2c_client *client, const struct i2c_device_id *id)
diff --git a/arch/sh/boards/mach-x3proto/gpio.c b/arch/sh/boards/mach-x3proto/gpio.c
index 3ea65e9..f035a7a 100644
--- a/arch/sh/boards/mach-x3proto/gpio.c
+++ b/arch/sh/boards/mach-x3proto/gpio.c
@@ -128,10 +128,8 @@ int __init x3proto_gpio_setup(void)
 	return 0;
 
 err_irq:
-	ret = gpiochip_remove(&x3proto_gpio_chip);
-	if (unlikely(ret))
-		pr_err("Failed deregistering GPIO\n");
-
+	gpiochip_remove(&x3proto_gpio_chip);
+	ret = 0;
 err_gpio:
 	synchronize_irq(ilsel);
 
diff --git a/drivers/bcma/driver_gpio.c b/drivers/bcma/driver_gpio.c
index d7f81ad..7dd70a7 100644
--- a/drivers/bcma/driver_gpio.c
+++ b/drivers/bcma/driver_gpio.c
@@ -250,5 +250,6 @@ int bcma_gpio_init(struct bcma_drv_cc *cc)
 int bcma_gpio_unregister(struct bcma_drv_cc *cc)
 {
 	bcma_gpio_irq_domain_exit(cc);
-	return gpiochip_remove(&cc->gpio);
+	gpiochip_remove(&cc->gpio);
+	return 0;
 }
diff --git a/drivers/gpio/gpio-74x164.c b/drivers/gpio/gpio-74x164.c
index e4ae298..e3d968f 100644
--- a/drivers/gpio/gpio-74x164.c
+++ b/drivers/gpio/gpio-74x164.c
@@ -167,13 +167,11 @@ exit_destroy:
 static int gen_74x164_remove(struct spi_device *spi)
 {
 	struct gen_74x164_chip *chip = spi_get_drvdata(spi);
-	int ret;
 
-	ret = gpiochip_remove(&chip->gpio_chip);
-	if (!ret)
-		mutex_destroy(&chip->lock);
+	gpiochip_remove(&chip->gpio_chip);
+	mutex_destroy(&chip->lock);
 
-	return ret;
+	return 0;
 }
 
 static const struct of_device_id gen_74x164_dt_ids[] = {
diff --git a/drivers/gpio/gpio-adnp.c b/drivers/gpio/gpio-adnp.c
index b2239d6..416b220 100644
--- a/drivers/gpio/gpio-adnp.c
+++ b/drivers/gpio/gpio-adnp.c
@@ -585,15 +585,8 @@ static int adnp_i2c_remove(struct i2c_client *client)
 {
 	struct adnp *adnp = i2c_get_clientdata(client);
 	struct device_node *np = client->dev.of_node;
-	int err;
-
-	err = gpiochip_remove(&adnp->gpio);
-	if (err < 0) {
-		dev_err(&client->dev, "%s failed: %d\n", "gpiochip_remove()",
-			err);
-		return err;
-	}
 
+	gpiochip_remove(&adnp->gpio);
 	if (of_find_property(np, "interrupt-controller", NULL))
 		adnp_irq_teardown(adnp);
 
diff --git a/drivers/gpio/gpio-adp5520.c b/drivers/gpio/gpio-adp5520.c
index 6132659..67927bc 100644
--- a/drivers/gpio/gpio-adp5520.c
+++ b/drivers/gpio/gpio-adp5520.c
@@ -169,15 +169,9 @@ err:
 static int adp5520_gpio_remove(struct platform_device *pdev)
 {
 	struct adp5520_gpio *dev;
-	int ret;
 
 	dev = platform_get_drvdata(pdev);
-	ret = gpiochip_remove(&dev->gpio_chip);
-	if (ret) {
-		dev_err(&pdev->dev, "%s failed, %d\n",
-				"gpiochip_remove()", ret);
-		return ret;
-	}
+	gpiochip_remove(&dev->gpio_chip);
 
 	return 0;
 }
diff --git a/drivers/gpio/gpio-adp5588.c b/drivers/gpio/gpio-adp5588.c
index d974020..5d7df22 100644
--- a/drivers/gpio/gpio-adp5588.c
+++ b/drivers/gpio/gpio-adp5588.c
@@ -472,11 +472,7 @@ static int adp5588_gpio_remove(struct i2c_client *client)
 	if (dev->irq_base)
 		free_irq(dev->client->irq, dev);
 
-	ret = gpiochip_remove(&dev->gpio_chip);
-	if (ret) {
-		dev_err(&client->dev, "gpiochip_remove failed %d\n", ret);
-		return ret;
-	}
+	gpiochip_remove(&dev->gpio_chip);
 
 	kfree(dev);
 	return 0;
diff --git a/drivers/gpio/gpio-amd8111.c b/drivers/gpio/gpio-amd8111.c
index 94e9992..3c09f1a6 100644
--- a/drivers/gpio/gpio-amd8111.c
+++ b/drivers/gpio/gpio-amd8111.c
@@ -232,8 +232,7 @@ out:
 
 static void __exit amd_gpio_exit(void)
 {
-	int err = gpiochip_remove(&gp.chip);
-	WARN_ON(err);
+	gpiochip_remove(&gp.chip);
 	ioport_unmap(gp.pm);
 	release_region(gp.pmbase + PMBASE_OFFSET, PMBASE_SIZE);
 }
diff --git a/drivers/gpio/gpio-arizona.c b/drivers/gpio/gpio-arizona.c
index 29bdff5..fe369f5 100644
--- a/drivers/gpio/gpio-arizona.c
+++ b/drivers/gpio/gpio-arizona.c
@@ -149,7 +149,8 @@ static int arizona_gpio_remove(struct platform_device *pdev)
 {
 	struct arizona_gpio *arizona_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&arizona_gpio->gpio_chip);
+	gpiochip_remove(&arizona_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver arizona_gpio_driver = {
diff --git a/drivers/gpio/gpio-cs5535.c b/drivers/gpio/gpio-cs5535.c
index c0a3aeb..92ec58f 100644
--- a/drivers/gpio/gpio-cs5535.c
+++ b/drivers/gpio/gpio-cs5535.c
@@ -358,14 +358,8 @@ done:
 static int cs5535_gpio_remove(struct platform_device *pdev)
 {
 	struct resource *r;
-	int err;
 
-	err = gpiochip_remove(&cs5535_gpio_chip.chip);
-	if (err) {
-		/* uhh? */
-		dev_err(&pdev->dev, "unable to remove gpio_chip?\n");
-		return err;
-	}
+	gpiochip_remove(&cs5535_gpio_chip.chip);
 
 	r = platform_get_resource(pdev, IORESOURCE_IO, 0);
 	release_region(r->start, resource_size(r));
diff --git a/drivers/gpio/gpio-da9052.c b/drivers/gpio/gpio-da9052.c
index 416cdf7..c5bccd4 100644
--- a/drivers/gpio/gpio-da9052.c
+++ b/drivers/gpio/gpio-da9052.c
@@ -237,7 +237,8 @@ static int da9052_gpio_remove(struct platform_device *pdev)
 {
 	struct da9052_gpio *gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&gpio->gp);
+	gpiochip_remove(&gpio->gp);
+	return 0;
 }
 
 static struct platform_driver da9052_gpio_driver = {
diff --git a/drivers/gpio/gpio-da9055.c b/drivers/gpio/gpio-da9055.c
index f992997..9167c43 100644
--- a/drivers/gpio/gpio-da9055.c
+++ b/drivers/gpio/gpio-da9055.c
@@ -174,7 +174,8 @@ static int da9055_gpio_remove(struct platform_device *pdev)
 {
 	struct da9055_gpio *gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&gpio->gp);
+	gpiochip_remove(&gpio->gp);
+	return 0;
 }
 
 static struct platform_driver da9055_gpio_driver = {
diff --git a/drivers/gpio/gpio-dwapb.c b/drivers/gpio/gpio-dwapb.c
index ed5711f..bcf677a 100644
--- a/drivers/gpio/gpio-dwapb.c
+++ b/drivers/gpio/gpio-dwapb.c
@@ -353,7 +353,7 @@ static void dwapb_gpio_unregister(struct dwapb_gpio *gpio)
 
 	for (m = 0; m < gpio->nr_ports; ++m)
 		if (gpio->ports[m].is_registered)
-			WARN_ON(gpiochip_remove(&gpio->ports[m].bgc.gc));
+			gpiochip_remove(&gpio->ports[m].bgc.gc);
 }
 
 static int dwapb_gpio_probe(struct platform_device *pdev)
diff --git a/drivers/gpio/gpio-em.c b/drivers/gpio/gpio-em.c
index 8765bd6..d39a1d1 100644
--- a/drivers/gpio/gpio-em.c
+++ b/drivers/gpio/gpio-em.c
@@ -410,11 +410,8 @@ err0:
 static int em_gio_remove(struct platform_device *pdev)
 {
 	struct em_gio_priv *p = platform_get_drvdata(pdev);
-	int ret;
 
-	ret = gpiochip_remove(&p->gpio_chip);
-	if (ret)
-		return ret;
+	gpiochip_remove(&p->gpio_chip);
 
 	irq_domain_remove(p->irq_domain);
 	return 0;
diff --git a/drivers/gpio/gpio-f7188x.c b/drivers/gpio/gpio-f7188x.c
index 8f73ee0..fd3202f 100644
--- a/drivers/gpio/gpio-f7188x.c
+++ b/drivers/gpio/gpio-f7188x.c
@@ -317,13 +317,7 @@ static int f7188x_gpio_probe(struct platform_device *pdev)
 err_gpiochip:
 	for (i = i - 1; i >= 0; i--) {
 		struct f7188x_gpio_bank *bank = &data->bank[i];
-		int tmp;
-
-		tmp = gpiochip_remove(&bank->chip);
-		if (tmp < 0)
-			dev_err(&pdev->dev,
-				"Failed to remove gpiochip %d: %d\n",
-				i, tmp);
+		gpiochip_remove(&bank->chip);
 	}
 
 	return err;
@@ -331,20 +325,12 @@ err_gpiochip:
 
 static int f7188x_gpio_remove(struct platform_device *pdev)
 {
-	int err;
 	int i;
 	struct f7188x_gpio_data *data = platform_get_drvdata(pdev);
 
 	for (i = 0; i < data->nr_bank; i++) {
 		struct f7188x_gpio_bank *bank = &data->bank[i];
-
-		err = gpiochip_remove(&bank->chip);
-		if (err) {
-			dev_err(&pdev->dev,
-				"Failed to remove GPIO gpiochip %d: %d\n",
-				i, err);
-			return err;
-		}
+		gpiochip_remove(&bank->chip);
 	}
 
 	return 0;
diff --git a/drivers/gpio/gpio-generic.c b/drivers/gpio/gpio-generic.c
index b5dff9e..1f4e0b0 100644
--- a/drivers/gpio/gpio-generic.c
+++ b/drivers/gpio/gpio-generic.c
@@ -390,7 +390,8 @@ static int bgpio_setup_direction(struct bgpio_chip *bgc,
 
 int bgpio_remove(struct bgpio_chip *bgc)
 {
-	return gpiochip_remove(&bgc->gc);
+	gpiochip_remove(&bgc->gc);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(bgpio_remove);
 
diff --git a/drivers/gpio/gpio-grgpio.c b/drivers/gpio/gpio-grgpio.c
index 84d2478..c380354 100644
--- a/drivers/gpio/gpio-grgpio.c
+++ b/drivers/gpio/gpio-grgpio.c
@@ -468,9 +468,7 @@ static int grgpio_remove(struct platform_device *ofdev)
 		}
 	}
 
-	ret = gpiochip_remove(&priv->bgc.gc);
-	if (ret)
-		goto out;
+	gpiochip_remove(&priv->bgc.gc);
 
 	if (priv->domain)
 		irq_domain_remove(priv->domain);
diff --git a/drivers/gpio/gpio-ich.c b/drivers/gpio/gpio-ich.c
index e73c675..acf00ee 100644
--- a/drivers/gpio/gpio-ich.c
+++ b/drivers/gpio/gpio-ich.c
@@ -510,14 +510,7 @@ add_err:
 
 static int ichx_gpio_remove(struct platform_device *pdev)
 {
-	int err;
-
-	err = gpiochip_remove(&ichx_priv.chip);
-	if (err) {
-		dev_err(&pdev->dev, "%s failed, %d\n",
-				"gpiochip_remove()", err);
-		return err;
-	}
+	gpiochip_remove(&ichx_priv.chip);
 
 	ichx_gpio_release_regions(ichx_priv.gpio_base, ichx_priv.use_gpio);
 	if (ichx_priv.pm_base)
diff --git a/drivers/gpio/gpio-it8761e.c b/drivers/gpio/gpio-it8761e.c
index 278b813..dadfc24 100644
--- a/drivers/gpio/gpio-it8761e.c
+++ b/drivers/gpio/gpio-it8761e.c
@@ -217,11 +217,7 @@ gpiochip_add_err:
 static void __exit it8761e_gpio_exit(void)
 {
 	if (gpio_ba) {
-		int ret = gpiochip_remove(&it8761e_gpio_chip);
-
-		WARN(ret, "%s(): gpiochip_remove() failed, ret=%d\n",
-				__func__, ret);
-
+		gpiochip_remove(&it8761e_gpio_chip);
 		release_region(gpio_ba, GPIO_IOSIZE);
 		gpio_ba = 0;
 	}
diff --git a/drivers/gpio/gpio-janz-ttl.c b/drivers/gpio/gpio-janz-ttl.c
index 2ecd3a0..eb5302c 100644
--- a/drivers/gpio/gpio-janz-ttl.c
+++ b/drivers/gpio/gpio-janz-ttl.c
@@ -214,14 +214,8 @@ out_return:
 static int ttl_remove(struct platform_device *pdev)
 {
 	struct ttl_module *mod = platform_get_drvdata(pdev);
-	struct device *dev = &pdev->dev;
-	int ret;
 
-	ret = gpiochip_remove(&mod->gpio);
-	if (ret) {
-		dev_err(dev, "unable to remove GPIO chip\n");
-		return ret;
-	}
+	gpiochip_remove(&mod->gpio);
 
 	iounmap(mod->regs);
 	kfree(mod);
diff --git a/drivers/gpio/gpio-kempld.c b/drivers/gpio/gpio-kempld.c
index c6d8817..3b2777d 100644
--- a/drivers/gpio/gpio-kempld.c
+++ b/drivers/gpio/gpio-kempld.c
@@ -199,7 +199,8 @@ static int kempld_gpio_remove(struct platform_device *pdev)
 {
 	struct kempld_gpio_data *gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&gpio->chip);
+	gpiochip_remove(&gpio->chip);
+	return 0;
 }
 
 static struct platform_driver kempld_gpio_driver = {
diff --git a/drivers/gpio/gpio-lp3943.c b/drivers/gpio/gpio-lp3943.c
index a0341c9..6bbdad8 100644
--- a/drivers/gpio/gpio-lp3943.c
+++ b/drivers/gpio/gpio-lp3943.c
@@ -216,7 +216,8 @@ static int lp3943_gpio_remove(struct platform_device *pdev)
 {
 	struct lp3943_gpio *lp3943_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&lp3943_gpio->chip);
+	gpiochip_remove(&lp3943_gpio->chip);
+	return 0;
 }
 
 static const struct of_device_id lp3943_gpio_of_match[] = {
diff --git a/drivers/gpio/gpio-lynxpoint.c b/drivers/gpio/gpio-lynxpoint.c
index 9a82a90..3d55d05 100644
--- a/drivers/gpio/gpio-lynxpoint.c
+++ b/drivers/gpio/gpio-lynxpoint.c
@@ -467,11 +467,8 @@ MODULE_DEVICE_TABLE(acpi, lynxpoint_gpio_acpi_match);
 static int lp_gpio_remove(struct platform_device *pdev)
 {
 	struct lp_gpio *lg = platform_get_drvdata(pdev);
-	int err;
 	pm_runtime_disable(&pdev->dev);
-	err = gpiochip_remove(&lg->chip);
-	if (err)
-		dev_warn(&pdev->dev, "failed to remove gpio_chip.\n");
+	gpiochip_remove(&lg->chip);
 	return 0;
 }
 
diff --git a/drivers/gpio/gpio-max730x.c b/drivers/gpio/gpio-max730x.c
index 8672755..95e1dd0 100644
--- a/drivers/gpio/gpio-max730x.c
+++ b/drivers/gpio/gpio-max730x.c
@@ -228,7 +228,6 @@ EXPORT_SYMBOL_GPL(__max730x_probe);
 int __max730x_remove(struct device *dev)
 {
 	struct max7301 *ts = dev_get_drvdata(dev);
-	int ret;
 
 	if (ts == NULL)
 		return -ENODEV;
@@ -236,14 +235,11 @@ int __max730x_remove(struct device *dev)
 	/* Power down the chip and disable IRQ output */
 	ts->write(dev, 0x04, 0x00);
 
-	ret = gpiochip_remove(&ts->chip);
-	if (!ret) {
-		mutex_destroy(&ts->lock);
-		kfree(ts);
-	} else
-		dev_err(dev, "Failed to remove GPIO controller: %d\n", ret);
+	gpiochip_remove(&ts->chip);
+	mutex_destroy(&ts->lock);
+	kfree(ts);
 
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(__max730x_remove);
 
diff --git a/drivers/gpio/gpio-max732x.c b/drivers/gpio/gpio-max732x.c
index 7c36f2b..6c67622 100644
--- a/drivers/gpio/gpio-max732x.c
+++ b/drivers/gpio/gpio-max732x.c
@@ -676,12 +676,7 @@ static int max732x_remove(struct i2c_client *client)
 		}
 	}
 
-	ret = gpiochip_remove(&chip->gpio_chip);
-	if (ret) {
-		dev_err(&client->dev, "%s failed, %d\n",
-				"gpiochip_remove()", ret);
-		return ret;
-	}
+	gpiochip_remove(&chip->gpio_chip);
 
 	max732x_irq_teardown(chip);
 
diff --git a/drivers/gpio/gpio-mc33880.c b/drivers/gpio/gpio-mc33880.c
index 553a80a..4e3e160 100644
--- a/drivers/gpio/gpio-mc33880.c
+++ b/drivers/gpio/gpio-mc33880.c
@@ -149,20 +149,15 @@ exit_destroy:
 static int mc33880_remove(struct spi_device *spi)
 {
 	struct mc33880 *mc;
-	int ret;
 
 	mc = spi_get_drvdata(spi);
 	if (mc == NULL)
 		return -ENODEV;
 
-	ret = gpiochip_remove(&mc->chip);
-	if (!ret)
-		mutex_destroy(&mc->lock);
-	else
-		dev_err(&spi->dev, "Failed to remove the GPIO controller: %d\n",
-			ret);
+	gpiochip_remove(&mc->chip);
+	mutex_destroy(&mc->lock);
 
-	return ret;
+	return 0;
 }
 
 static struct spi_driver mc33880_driver = {
diff --git a/drivers/gpio/gpio-mc9s08dz60.c b/drivers/gpio/gpio-mc9s08dz60.c
index dce35ff..d62b4f8 100644
--- a/drivers/gpio/gpio-mc9s08dz60.c
+++ b/drivers/gpio/gpio-mc9s08dz60.c
@@ -118,7 +118,8 @@ static int mc9s08dz60_remove(struct i2c_client *client)
 
 	mc9s = i2c_get_clientdata(client);
 
-	return gpiochip_remove(&mc9s->chip);
+	gpiochip_remove(&mc9s->chip);
+	return 0;
 }
 
 static const struct i2c_device_id mc9s08dz60_id[] = {
diff --git a/drivers/gpio/gpio-mcp23s08.c b/drivers/gpio/gpio-mcp23s08.c
index 99a6831..74ffb66 100644
--- a/drivers/gpio/gpio-mcp23s08.c
+++ b/drivers/gpio/gpio-mcp23s08.c
@@ -812,16 +812,14 @@ fail:
 static int mcp230xx_remove(struct i2c_client *client)
 {
 	struct mcp23s08 *mcp = i2c_get_clientdata(client);
-	int status;
 
 	if (client->irq && mcp->irq_controller)
 		mcp23s08_irq_teardown(mcp);
 
-	status = gpiochip_remove(&mcp->chip);
-	if (status == 0)
-		kfree(mcp);
+	gpiochip_remove(&mcp->chip);
+	kfree(mcp);
 
-	return status;
+	return 0;
 }
 
 static const struct i2c_device_id mcp230xx_id[] = {
@@ -957,13 +955,10 @@ static int mcp23s08_probe(struct spi_device *spi)
 
 fail:
 	for (addr = 0; addr < ARRAY_SIZE(data->mcp); addr++) {
-		int tmp;
 
 		if (!data->mcp[addr])
 			continue;
-		tmp = gpiochip_remove(&data->mcp[addr]->chip);
-		if (tmp < 0)
-			dev_err(&spi->dev, "%s --> %d\n", "remove", tmp);
+		gpiochip_remove(&data->mcp[addr]->chip);
 	}
 	kfree(data);
 	return status;
@@ -973,23 +968,16 @@ static int mcp23s08_remove(struct spi_device *spi)
 {
 	struct mcp23s08_driver_data	*data = spi_get_drvdata(spi);
 	unsigned			addr;
-	int				status = 0;
 
 	for (addr = 0; addr < ARRAY_SIZE(data->mcp); addr++) {
-		int tmp;
 
 		if (!data->mcp[addr])
 			continue;
 
-		tmp = gpiochip_remove(&data->mcp[addr]->chip);
-		if (tmp < 0) {
-			dev_err(&spi->dev, "%s --> %d\n", "remove", tmp);
-			status = tmp;
-		}
+		gpiochip_remove(&data->mcp[addr]->chip);
 	}
-	if (status == 0)
-		kfree(data);
-	return status;
+	kfree(data);
+	return 0;
 }
 
 static const struct spi_device_id mcp23s08_ids[] = {
diff --git a/drivers/gpio/gpio-ml-ioh.c b/drivers/gpio/gpio-ml-ioh.c
index d51329d..5536108 100644
--- a/drivers/gpio/gpio-ml-ioh.c
+++ b/drivers/gpio/gpio-ml-ioh.c
@@ -497,8 +497,7 @@ err_irq_alloc_descs:
 err_gpiochip_add:
 	while (--i >= 0) {
 		chip--;
-		if (gpiochip_remove(&chip->gpio))
-			dev_err(&pdev->dev, "Failed gpiochip_remove(%d)\n", i);
+		gpiochip_remove(&chip->gpio);
 	}
 	kfree(chip_save);
 
@@ -519,7 +518,6 @@ err_pci_enable:
 
 static void ioh_gpio_remove(struct pci_dev *pdev)
 {
-	int err;
 	int i;
 	struct ioh_gpio *chip = pci_get_drvdata(pdev);
 	void *chip_save;
@@ -530,9 +528,7 @@ static void ioh_gpio_remove(struct pci_dev *pdev)
 
 	for (i = 0; i < 8; i++, chip++) {
 		irq_free_descs(chip->irq_base, num_ports[i]);
-		err = gpiochip_remove(&chip->gpio);
-		if (err)
-			dev_err(&pdev->dev, "Failed gpiochip_remove\n");
+		gpiochip_remove(&chip->gpio);
 	}
 
 	chip = chip_save;
diff --git a/drivers/gpio/gpio-msm-v2.c b/drivers/gpio/gpio-msm-v2.c
index a3351ac..94f5767 100644
--- a/drivers/gpio/gpio-msm-v2.c
+++ b/drivers/gpio/gpio-msm-v2.c
@@ -438,10 +438,7 @@ MODULE_DEVICE_TABLE(of, msm_gpio_of_match);
 
 static int msm_gpio_remove(struct platform_device *dev)
 {
-	int ret = gpiochip_remove(&msm_gpio.gpio_chip);
-
-	if (ret < 0)
-		return ret;
+	gpiochip_remove(&msm_gpio.gpio_chip);
 
 	irq_set_handler(msm_gpio.summary_irq, NULL);
 
diff --git a/drivers/gpio/gpio-mxc.c b/drivers/gpio/gpio-mxc.c
index db83b3c..f4e54a9 100644
--- a/drivers/gpio/gpio-mxc.c
+++ b/drivers/gpio/gpio-mxc.c
@@ -485,7 +485,7 @@ static int mxc_gpio_probe(struct platform_device *pdev)
 out_irqdesc_free:
 	irq_free_descs(irq_base, 32);
 out_gpiochip_remove:
-	WARN_ON(gpiochip_remove(&port->bgc.gc) < 0);
+	gpiochip_remove(&port->bgc.gc);
 out_bgpio_remove:
 	bgpio_remove(&port->bgc);
 out_bgio:
diff --git a/drivers/gpio/gpio-octeon.c b/drivers/gpio/gpio-octeon.c
index dbb0854..5c5770c 100644
--- a/drivers/gpio/gpio-octeon.c
+++ b/drivers/gpio/gpio-octeon.c
@@ -129,7 +129,8 @@ out:
 static int octeon_gpio_remove(struct platform_device *pdev)
 {
 	struct gpio_chip *chip = pdev->dev.platform_data;
-	return gpiochip_remove(chip);
+	gpiochip_remove(chip);
+	return 0;
 }
 
 static struct of_device_id octeon_gpio_match[] = {
diff --git a/drivers/gpio/gpio-palmas.c b/drivers/gpio/gpio-palmas.c
index da9d332..4686349 100644
--- a/drivers/gpio/gpio-palmas.c
+++ b/drivers/gpio/gpio-palmas.c
@@ -212,7 +212,8 @@ static int palmas_gpio_remove(struct platform_device *pdev)
 {
 	struct palmas_gpio *palmas_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&palmas_gpio->gpio_chip);
+	gpiochip_remove(&palmas_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver palmas_gpio_driver = {
diff --git a/drivers/gpio/gpio-pca953x.c b/drivers/gpio/gpio-pca953x.c
index d550d8e..fa79c72 100644
--- a/drivers/gpio/gpio-pca953x.c
+++ b/drivers/gpio/gpio-pca953x.c
@@ -791,12 +791,7 @@ static int pca953x_remove(struct i2c_client *client)
 		}
 	}
 
-	ret = gpiochip_remove(&chip->gpio_chip);
-	if (ret) {
-		dev_err(&client->dev, "%s failed, %d\n",
-				"gpiochip_remove()", ret);
-		return ret;
-	}
+	gpiochip_remove(&chip->gpio_chip);
 
 	return 0;
 }
diff --git a/drivers/gpio/gpio-pcf857x.c b/drivers/gpio/gpio-pcf857x.c
index 8273582..5c5fa8e 100644
--- a/drivers/gpio/gpio-pcf857x.c
+++ b/drivers/gpio/gpio-pcf857x.c
@@ -443,9 +443,7 @@ static int pcf857x_remove(struct i2c_client *client)
 	if (client->irq)
 		pcf857x_irq_domain_cleanup(gpio);
 
-	status = gpiochip_remove(&gpio->chip);
-	if (status)
-		dev_err(&client->dev, "%s --> %d\n", "remove", status);
+	gpiochip_remove(&gpio->chip);
 	return status;
 }
 
diff --git a/drivers/gpio/gpio-pch.c b/drivers/gpio/gpio-pch.c
index 83a1563..98d03ca 100644
--- a/drivers/gpio/gpio-pch.c
+++ b/drivers/gpio/gpio-pch.c
@@ -425,9 +425,7 @@ end:
 
 err_request_irq:
 	irq_free_descs(irq_base, gpio_pins[chip->ioh]);
-
-	if (gpiochip_remove(&chip->gpio))
-		dev_err(&pdev->dev, "%s gpiochip_remove failed\n", __func__);
+	gpiochip_remove(&chip->gpio);
 
 err_gpiochip_add:
 	pci_iounmap(pdev, chip->base);
@@ -446,7 +444,6 @@ err_pci_enable:
 
 static void pch_gpio_remove(struct pci_dev *pdev)
 {
-	int err;
 	struct pch_gpio *chip = pci_get_drvdata(pdev);
 
 	if (chip->irq_base != -1) {
@@ -455,10 +452,7 @@ static void pch_gpio_remove(struct pci_dev *pdev)
 		irq_free_descs(chip->irq_base, gpio_pins[chip->ioh]);
 	}
 
-	err = gpiochip_remove(&chip->gpio);
-	if (err)
-		dev_err(&pdev->dev, "Failed gpiochip_remove\n");
-
+	gpiochip_remove(&chip->gpio);
 	pci_iounmap(pdev, chip->base);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
diff --git a/drivers/gpio/gpio-rc5t583.c b/drivers/gpio/gpio-rc5t583.c
index 9b42317..dc43cfb 100644
--- a/drivers/gpio/gpio-rc5t583.c
+++ b/drivers/gpio/gpio-rc5t583.c
@@ -150,7 +150,8 @@ static int rc5t583_gpio_remove(struct platform_device *pdev)
 {
 	struct rc5t583_gpio *rc5t583_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&rc5t583_gpio->gpio_chip);
+	gpiochip_remove(&rc5t583_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver rc5t583_gpio_driver = {
diff --git a/drivers/gpio/gpio-rcar.c b/drivers/gpio/gpio-rcar.c
index 03c9148..f6e92a8 100644
--- a/drivers/gpio/gpio-rcar.c
+++ b/drivers/gpio/gpio-rcar.c
@@ -466,11 +466,8 @@ err0:
 static int gpio_rcar_remove(struct platform_device *pdev)
 {
 	struct gpio_rcar_priv *p = platform_get_drvdata(pdev);
-	int ret;
 
-	ret = gpiochip_remove(&p->gpio_chip);
-	if (ret)
-		return ret;
+	gpiochip_remove(&p->gpio_chip);
 
 	irq_domain_remove(p->irq_domain);
 	return 0;
diff --git a/drivers/gpio/gpio-rdc321x.c b/drivers/gpio/gpio-rdc321x.c
index 88577c3..cad37f0 100644
--- a/drivers/gpio/gpio-rdc321x.c
+++ b/drivers/gpio/gpio-rdc321x.c
@@ -206,16 +206,13 @@ out_free:
 
 static int rdc321x_gpio_remove(struct platform_device *pdev)
 {
-	int ret;
 	struct rdc321x_gpio *rdc321x_gpio_dev = platform_get_drvdata(pdev);
 
-	ret = gpiochip_remove(&rdc321x_gpio_dev->chip);
-	if (ret)
-		dev_err(&pdev->dev, "failed to unregister chip\n");
+	gpiochip_remove(&rdc321x_gpio_dev->chip);
 
 	kfree(rdc321x_gpio_dev);
 
-	return ret;
+	return 0;
 }
 
 static struct platform_driver rdc321x_gpio_driver = {
diff --git a/drivers/gpio/gpio-sch.c b/drivers/gpio/gpio-sch.c
index 5af6571..2204a3e 100644
--- a/drivers/gpio/gpio-sch.c
+++ b/drivers/gpio/gpio-sch.c
@@ -272,8 +272,7 @@ static int sch_gpio_probe(struct platform_device *pdev)
 	return 0;
 
 err_sch_gpio_resume:
-	if (gpiochip_remove(&sch_gpio_core))
-		dev_err(&pdev->dev, "%s gpiochip_remove failed\n", __func__);
+	gpiochip_remove(&sch_gpio_core);
 
 err_sch_gpio_core:
 	release_region(res->start, resource_size(res));
@@ -286,23 +285,14 @@ static int sch_gpio_remove(struct platform_device *pdev)
 {
 	struct resource *res;
 	if (gpio_ba) {
-		int err;
 
-		err  = gpiochip_remove(&sch_gpio_core);
-		if (err)
-			dev_err(&pdev->dev, "%s failed, %d\n",
-				"gpiochip_remove()", err);
-		err = gpiochip_remove(&sch_gpio_resume);
-		if (err)
-			dev_err(&pdev->dev, "%s failed, %d\n",
-				"gpiochip_remove()", err);
+		gpiochip_remove(&sch_gpio_core);
+		gpiochip_remove(&sch_gpio_resume);
 
 		res = platform_get_resource(pdev, IORESOURCE_IO, 0);
 
 		release_region(res->start, resource_size(res));
 		gpio_ba = 0;
-
-		return err;
 	}
 
 	return 0;
diff --git a/drivers/gpio/gpio-sch311x.c b/drivers/gpio/gpio-sch311x.c
index 0357387..4e42299 100644
--- a/drivers/gpio/gpio-sch311x.c
+++ b/drivers/gpio/gpio-sch311x.c
@@ -291,14 +291,12 @@ static int sch311x_gpio_remove(struct platform_device *pdev)
 {
 	struct sch311x_pdev_data *pdata = pdev->dev.platform_data;
 	struct sch311x_gpio_priv *priv = platform_get_drvdata(pdev);
-	int err, i;
+	int i;
 
 	release_region(pdata->runtime_reg + GP1, 6);
 
 	for (i = 0; i < ARRAY_SIZE(priv->blocks); i++) {
-		err = gpiochip_remove(&priv->blocks[i].chip);
-		if (err)
-			return err;
+		gpiochip_remove(&priv->blocks[i].chip);
 		dev_info(&pdev->dev,
 			 "SMSC SCH311x GPIO block %d unregistered.\n", i);
 	}
diff --git a/drivers/gpio/gpio-sodaville.c b/drivers/gpio/gpio-sodaville.c
index 7c6c518..d8da36c 100644
--- a/drivers/gpio/gpio-sodaville.c
+++ b/drivers/gpio/gpio-sodaville.c
@@ -265,9 +265,7 @@ static void sdv_gpio_remove(struct pci_dev *pdev)
 	free_irq(pdev->irq, sd);
 	irq_free_descs(sd->irq_base, SDV_NUM_PUB_GPIOS);
 
-	if (gpiochip_remove(&sd->bgpio.gc))
-		dev_err(&pdev->dev, "gpiochip_remove() failed.\n");
-
+	gpiochip_remove(&sd->bgpio.gc);
 	pci_release_region(pdev, GPIO_BAR);
 	iounmap(sd->gpio_pub_base);
 	pci_disable_device(pdev);
diff --git a/drivers/gpio/gpio-stmpe.c b/drivers/gpio/gpio-stmpe.c
index 2776a09..69bf345 100644
--- a/drivers/gpio/gpio-stmpe.c
+++ b/drivers/gpio/gpio-stmpe.c
@@ -415,17 +415,11 @@ static int stmpe_gpio_remove(struct platform_device *pdev)
 	struct stmpe *stmpe = stmpe_gpio->stmpe;
 	struct stmpe_gpio_platform_data *pdata = stmpe->pdata->gpio;
 	int irq = platform_get_irq(pdev, 0);
-	int ret;
 
 	if (pdata && pdata->remove)
 		pdata->remove(stmpe, stmpe_gpio->chip.base);
 
-	ret = gpiochip_remove(&stmpe_gpio->chip);
-	if (ret < 0) {
-		dev_err(stmpe_gpio->dev,
-			"unable to remove gpiochip: %d\n", ret);
-		return ret;
-	}
+	gpiochip_remove(&stmpe_gpio->chip);
 
 	stmpe_disable(stmpe, STMPE_BLOCK_GPIO);
 
diff --git a/drivers/gpio/gpio-sx150x.c b/drivers/gpio/gpio-sx150x.c
index 13d73fb..de79286 100644
--- a/drivers/gpio/gpio-sx150x.c
+++ b/drivers/gpio/gpio-sx150x.c
@@ -616,19 +616,16 @@ static int sx150x_probe(struct i2c_client *client,
 
 	return 0;
 probe_fail_post_gpiochip_add:
-	WARN_ON(gpiochip_remove(&chip->gpio_chip) < 0);
+	gpiochip_remove(&chip->gpio_chip);
 	return rc;
 }
 
 static int sx150x_remove(struct i2c_client *client)
 {
 	struct sx150x_chip *chip;
-	int rc;
 
 	chip = i2c_get_clientdata(client);
-	rc = gpiochip_remove(&chip->gpio_chip);
-	if (rc < 0)
-		return rc;
+	gpiochip_remove(&chip->gpio_chip);
 
 	if (chip->irq_summary >= 0)
 		sx150x_remove_irq_chip(chip);
diff --git a/drivers/gpio/gpio-syscon.c b/drivers/gpio/gpio-syscon.c
index b50fe12..30884fb 100644
--- a/drivers/gpio/gpio-syscon.c
+++ b/drivers/gpio/gpio-syscon.c
@@ -172,7 +172,8 @@ static int syscon_gpio_remove(struct platform_device *pdev)
 {
 	struct syscon_gpio_priv *priv = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&priv->chip);
+	gpiochip_remove(&priv->chip);
+	return 0;
 }
 
 static struct platform_driver syscon_gpio_driver = {
diff --git a/drivers/gpio/gpio-tb10x.c b/drivers/gpio/gpio-tb10x.c
index 07bce97..9e615be 100644
--- a/drivers/gpio/gpio-tb10x.c
+++ b/drivers/gpio/gpio-tb10x.c
@@ -291,7 +291,6 @@ fail_ioremap:
 static int __exit tb10x_gpio_remove(struct platform_device *pdev)
 {
 	struct tb10x_gpio *tb10x_gpio = platform_get_drvdata(pdev);
-	int ret;
 
 	if (tb10x_gpio->gc.to_irq) {
 		irq_remove_generic_chip(tb10x_gpio->domain->gc->gc[0],
@@ -300,9 +299,7 @@ static int __exit tb10x_gpio_remove(struct platform_device *pdev)
 		irq_domain_remove(tb10x_gpio->domain);
 		free_irq(tb10x_gpio->irq, tb10x_gpio);
 	}
-	ret = gpiochip_remove(&tb10x_gpio->gc);
-	if (ret)
-		return ret;
+	gpiochip_remove(&tb10x_gpio->gc);
 
 	return 0;
 }
diff --git a/drivers/gpio/gpio-tc3589x.c b/drivers/gpio/gpio-tc3589x.c
index 1019320..0501c22 100644
--- a/drivers/gpio/gpio-tc3589x.c
+++ b/drivers/gpio/gpio-tc3589x.c
@@ -393,17 +393,11 @@ static int tc3589x_gpio_remove(struct platform_device *pdev)
 	struct tc3589x *tc3589x = tc3589x_gpio->tc3589x;
 	struct tc3589x_gpio_platform_data *pdata = tc3589x->pdata->gpio;
 	int irq = platform_get_irq(pdev, 0);
-	int ret;
 
 	if (pdata && pdata->remove)
 		pdata->remove(tc3589x, tc3589x_gpio->chip.base);
 
-	ret = gpiochip_remove(&tc3589x_gpio->chip);
-	if (ret < 0) {
-		dev_err(tc3589x_gpio->dev,
-			"unable to remove gpiochip: %d\n", ret);
-		return ret;
-	}
+	gpiochip_remove(&tc3589x_gpio->chip);
 
 	free_irq(irq, tc3589x_gpio);
 
diff --git a/drivers/gpio/gpio-timberdale.c b/drivers/gpio/gpio-timberdale.c
index f9a8fbd..54aac4d 100644
--- a/drivers/gpio/gpio-timberdale.c
+++ b/drivers/gpio/gpio-timberdale.c
@@ -317,7 +317,6 @@ err_mem:
 
 static int timbgpio_remove(struct platform_device *pdev)
 {
-	int err;
 	struct timbgpio_platform_data *pdata = dev_get_platdata(&pdev->dev);
 	struct timbgpio *tgpio = platform_get_drvdata(pdev);
 	struct resource *iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -334,9 +333,7 @@ static int timbgpio_remove(struct platform_device *pdev)
 		irq_set_handler_data(irq, NULL);
 	}
 
-	err = gpiochip_remove(&tgpio->gpio);
-	if (err)
-		printk(KERN_ERR DRIVER_NAME": failed to remove gpio_chip\n");
+	gpiochip_remove(&tgpio->gpio);
 
 	iounmap(tgpio->membase);
 	release_mem_region(iomem->start, resource_size(iomem));
diff --git a/drivers/gpio/gpio-tps6586x.c b/drivers/gpio/gpio-tps6586x.c
index 8994dfa..ec6a769 100644
--- a/drivers/gpio/gpio-tps6586x.c
+++ b/drivers/gpio/gpio-tps6586x.c
@@ -139,7 +139,8 @@ static int tps6586x_gpio_remove(struct platform_device *pdev)
 {
 	struct tps6586x_gpio *tps6586x_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&tps6586x_gpio->gpio_chip);
+	gpiochip_remove(&tps6586x_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver tps6586x_gpio_driver = {
diff --git a/drivers/gpio/gpio-tps65910.c b/drivers/gpio/gpio-tps65910.c
index b6e818e..640f522 100644
--- a/drivers/gpio/gpio-tps65910.c
+++ b/drivers/gpio/gpio-tps65910.c
@@ -192,7 +192,8 @@ static int tps65910_gpio_remove(struct platform_device *pdev)
 {
 	struct tps65910_gpio *tps65910_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&tps65910_gpio->gpio_chip);
+	gpiochip_remove(&tps65910_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver tps65910_gpio_driver = {
diff --git a/drivers/gpio/gpio-tps65912.c b/drivers/gpio/gpio-tps65912.c
index 59ee486..22052d8 100644
--- a/drivers/gpio/gpio-tps65912.c
+++ b/drivers/gpio/gpio-tps65912.c
@@ -117,7 +117,8 @@ static int tps65912_gpio_remove(struct platform_device *pdev)
 {
 	struct tps65912_gpio_data  *tps65912_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&tps65912_gpio->gpio_chip);
+	gpiochip_remove(&tps65912_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver tps65912_gpio_driver = {
diff --git a/drivers/gpio/gpio-ts5500.c b/drivers/gpio/gpio-ts5500.c
index 3df3ebd..de18591 100644
--- a/drivers/gpio/gpio-ts5500.c
+++ b/drivers/gpio/gpio-ts5500.c
@@ -427,8 +427,7 @@ static int ts5500_dio_probe(struct platform_device *pdev)
 
 	return 0;
 cleanup:
-	if (gpiochip_remove(&priv->gpio_chip))
-		dev_err(dev, "failed to remove gpio chip\n");
+	gpiochip_remove(&priv->gpio_chip);
 	return ret;
 }
 
@@ -437,7 +436,8 @@ static int ts5500_dio_remove(struct platform_device *pdev)
 	struct ts5500_priv *priv = platform_get_drvdata(pdev);
 
 	ts5500_disable_irq(priv);
-	return gpiochip_remove(&priv->gpio_chip);
+	gpiochip_remove(&priv->gpio_chip);
+	return 0;
 }
 
 static struct platform_device_id ts5500_dio_ids[] = {
diff --git a/drivers/gpio/gpio-twl4030.c b/drivers/gpio/gpio-twl4030.c
index 3ebb1a5..0f22ba3 100644
--- a/drivers/gpio/gpio-twl4030.c
+++ b/drivers/gpio/gpio-twl4030.c
@@ -583,9 +583,7 @@ static int gpio_twl4030_remove(struct platform_device *pdev)
 		}
 	}
 
-	status = gpiochip_remove(&priv->gpio_chip);
-	if (status < 0)
-		return status;
+	gpiochip_remove(&priv->gpio_chip);
 
 	if (is_module())
 		return 0;
diff --git a/drivers/gpio/gpio-twl6040.c b/drivers/gpio/gpio-twl6040.c
index 0caf5cd..f28e04b 100644
--- a/drivers/gpio/gpio-twl6040.c
+++ b/drivers/gpio/gpio-twl6040.c
@@ -111,7 +111,8 @@ static int gpo_twl6040_probe(struct platform_device *pdev)
 
 static int gpo_twl6040_remove(struct platform_device *pdev)
 {
-	return gpiochip_remove(&twl6040gpo_chip);
+	gpiochip_remove(&twl6040gpo_chip);
+	return 0;
 }
 
 /* Note:  this hardware lives inside an I2C-based multi-function device. */
diff --git a/drivers/gpio/gpio-ucb1400.c b/drivers/gpio/gpio-ucb1400.c
index 2445fe7..ee325a4 100644
--- a/drivers/gpio/gpio-ucb1400.c
+++ b/drivers/gpio/gpio-ucb1400.c
@@ -89,7 +89,7 @@ static int ucb1400_gpio_remove(struct platform_device *dev)
 			return err;
 	}
 
-	err = gpiochip_remove(&ucb->gc);
+	gpiochip_remove(&ucb->gc);
 	return err;
 }
 
diff --git a/drivers/gpio/gpio-viperboard.c b/drivers/gpio/gpio-viperboard.c
index 79e3b58..e2a11f2 100644
--- a/drivers/gpio/gpio-viperboard.c
+++ b/drivers/gpio/gpio-viperboard.c
@@ -446,8 +446,7 @@ static int vprbrd_gpio_probe(struct platform_device *pdev)
 	return ret;
 
 err_gpiob:
-	if (gpiochip_remove(&vb_gpio->gpioa))
-		dev_err(&pdev->dev, "%s gpiochip_remove failed\n", __func__);
+	gpiochip_remove(&vb_gpio->gpioa);
 
 err_gpioa:
 	return ret;
@@ -456,13 +455,10 @@ err_gpioa:
 static int vprbrd_gpio_remove(struct platform_device *pdev)
 {
 	struct vprbrd_gpio *vb_gpio = platform_get_drvdata(pdev);
-	int ret;
 
-	ret = gpiochip_remove(&vb_gpio->gpiob);
-	if (ret == 0)
-		ret = gpiochip_remove(&vb_gpio->gpioa);
+	gpiochip_remove(&vb_gpio->gpiob);
 
-	return ret;
+	return 0;
 }
 
 static struct platform_driver vprbrd_gpio_driver = {
diff --git a/drivers/gpio/gpio-vx855.c b/drivers/gpio/gpio-vx855.c
index 0fd23b6..85971d4 100644
--- a/drivers/gpio/gpio-vx855.c
+++ b/drivers/gpio/gpio-vx855.c
@@ -288,8 +288,7 @@ static int vx855gpio_remove(struct platform_device *pdev)
 	struct vx855_gpio *vg = platform_get_drvdata(pdev);
 	struct resource *res;
 
-	if (gpiochip_remove(&vg->gpio))
-		dev_err(&pdev->dev, "unable to remove gpio_chip?\n");
+	gpiochip_remove(&vg->gpio);
 
 	if (vg->gpi_reserved) {
 		res = platform_get_resource(pdev, IORESOURCE_IO, 0);
diff --git a/drivers/gpio/gpio-wm831x.c b/drivers/gpio/gpio-wm831x.c
index b18a1a2..58ce75c 100644
--- a/drivers/gpio/gpio-wm831x.c
+++ b/drivers/gpio/gpio-wm831x.c
@@ -279,7 +279,8 @@ static int wm831x_gpio_remove(struct platform_device *pdev)
 {
 	struct wm831x_gpio *wm831x_gpio = platform_get_drvdata(pdev);
 
-	return  gpiochip_remove(&wm831x_gpio->gpio_chip);
+	gpiochip_remove(&wm831x_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver wm831x_gpio_driver = {
diff --git a/drivers/gpio/gpio-wm8350.c b/drivers/gpio/gpio-wm8350.c
index 2487f9d..060b893 100644
--- a/drivers/gpio/gpio-wm8350.c
+++ b/drivers/gpio/gpio-wm8350.c
@@ -145,7 +145,8 @@ static int wm8350_gpio_remove(struct platform_device *pdev)
 {
 	struct wm8350_gpio_data *wm8350_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&wm8350_gpio->gpio_chip);
+	gpiochip_remove(&wm8350_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver wm8350_gpio_driver = {
diff --git a/drivers/gpio/gpio-wm8994.c b/drivers/gpio/gpio-wm8994.c
index d93b6b5..6f5e42d 100644
--- a/drivers/gpio/gpio-wm8994.c
+++ b/drivers/gpio/gpio-wm8994.c
@@ -285,7 +285,8 @@ static int wm8994_gpio_remove(struct platform_device *pdev)
 {
 	struct wm8994_gpio *wm8994_gpio = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&wm8994_gpio->gpio_chip);
+	gpiochip_remove(&wm8994_gpio->gpio_chip);
+	return 0;
 }
 
 static struct platform_driver wm8994_gpio_driver = {
diff --git a/drivers/hid/hid-cp2112.c b/drivers/hid/hid-cp2112.c
index 56be85a..a7f1b4b 100644
--- a/drivers/hid/hid-cp2112.c
+++ b/drivers/hid/hid-cp2112.c
@@ -964,8 +964,7 @@ static int cp2112_probe(struct hid_device *hdev, const struct hid_device_id *id)
 	return ret;
 
 err_gpiochip_remove:
-	if (gpiochip_remove(&dev->gc) < 0)
-		hid_err(hdev, "error removing gpio chip\n");
+	gpiochip_remove(&dev->gc);
 err_free_i2c:
 	i2c_del_adapter(&dev->adap);
 err_free_dev:
@@ -984,8 +983,7 @@ static void cp2112_remove(struct hid_device *hdev)
 	struct cp2112_device *dev = hid_get_drvdata(hdev);
 
 	sysfs_remove_group(&hdev->dev.kobj, &cp2112_attr_group);
-	if (gpiochip_remove(&dev->gc))
-		hid_err(hdev, "unable to remove gpio chip\n");
+	gpiochip_remove(&dev->gc);
 	i2c_del_adapter(&dev->adap);
 	/* i2c_del_adapter has finished removing all i2c devices from our
 	 * adapter. Well behaved devices should no longer call our cp2112_xfer
diff --git a/drivers/input/keyboard/adp5588-keys.c b/drivers/input/keyboard/adp5588-keys.c
index 5ef7fcf..b97ed44 100644
--- a/drivers/input/keyboard/adp5588-keys.c
+++ b/drivers/input/keyboard/adp5588-keys.c
@@ -251,9 +251,7 @@ static void adp5588_gpio_remove(struct adp5588_kpad *kpad)
 			dev_warn(dev, "teardown failed %d\n", error);
 	}
 
-	error = gpiochip_remove(&kpad->gc);
-	if (error)
-		dev_warn(dev, "gpiochip_remove failed %d\n", error);
+	gpiochip_remove(&kpad->gc);
 }
 #else
 static inline int adp5588_gpio_add(struct adp5588_kpad *kpad)
diff --git a/drivers/input/keyboard/adp5589-keys.c b/drivers/input/keyboard/adp5589-keys.c
index 6329549..a452677 100644
--- a/drivers/input/keyboard/adp5589-keys.c
+++ b/drivers/input/keyboard/adp5589-keys.c
@@ -567,9 +567,7 @@ static void adp5589_gpio_remove(struct adp5589_kpad *kpad)
 			dev_warn(dev, "teardown failed %d\n", error);
 	}
 
-	error = gpiochip_remove(&kpad->gc);
-	if (error)
-		dev_warn(dev, "gpiochip_remove failed %d\n", error);
+	gpiochip_remove(&kpad->gc);
 }
 #else
 static inline int adp5589_gpio_add(struct adp5589_kpad *kpad)
diff --git a/drivers/input/touchscreen/ad7879.c b/drivers/input/touchscreen/ad7879.c
index fce5906..1eb9d3c 100644
--- a/drivers/input/touchscreen/ad7879.c
+++ b/drivers/input/touchscreen/ad7879.c
@@ -470,14 +470,10 @@ static int ad7879_gpio_add(struct ad7879 *ts,
 static void ad7879_gpio_remove(struct ad7879 *ts)
 {
 	const struct ad7879_platform_data *pdata = dev_get_platdata(ts->dev);
-	int ret;
 
-	if (pdata->gpio_export) {
-		ret = gpiochip_remove(&ts->gc);
-		if (ret)
-			dev_err(ts->dev, "failed to remove gpio %d\n",
-				ts->gc.base);
-	}
+	if (pdata->gpio_export)
+		gpiochip_remove(&ts->gc);
+
 }
 #else
 static inline int ad7879_gpio_add(struct ad7879 *ts,
diff --git a/drivers/leds/leds-pca9532.c b/drivers/leds/leds-pca9532.c
index 4a0e786..5a6363d 100644
--- a/drivers/leds/leds-pca9532.c
+++ b/drivers/leds/leds-pca9532.c
@@ -319,14 +319,8 @@ static int pca9532_destroy_devices(struct pca9532_data *data, int n_devs)
 	}
 
 #ifdef CONFIG_LEDS_PCA9532_GPIO
-	if (data->gpio.dev) {
-		int err = gpiochip_remove(&data->gpio);
-		if (err) {
-			dev_err(&data->client->dev, "%s failed, %d\n",
-						"gpiochip_remove()", err);
-			return err;
-		}
-	}
+	if (data->gpio.dev)
+		gpiochip_remove(&data->gpio);
 #endif
 
 	return 0;
diff --git a/drivers/leds/leds-tca6507.c b/drivers/leds/leds-tca6507.c
index 3d9e267..20fa8e7 100644
--- a/drivers/leds/leds-tca6507.c
+++ b/drivers/leds/leds-tca6507.c
@@ -667,11 +667,8 @@ static int tca6507_probe_gpios(struct i2c_client *client,
 
 static void tca6507_remove_gpio(struct tca6507_chip *tca)
 {
-	if (tca->gpio.ngpio) {
-		int err = gpiochip_remove(&tca->gpio);
-		dev_err(&tca->client->dev, "%s failed, %d\n",
-			"gpiochip_remove()", err);
-	}
+	if (tca->gpio.ngpio)
+		gpiochip_remove(&tca->gpio);
 }
 #else /* CONFIG_GPIOLIB */
 static int tca6507_probe_gpios(struct i2c_client *client,
diff --git a/drivers/media/dvb-frontends/cxd2820r_core.c b/drivers/media/dvb-frontends/cxd2820r_core.c
index 03930d5..51ef8931 100644
--- a/drivers/media/dvb-frontends/cxd2820r_core.c
+++ b/drivers/media/dvb-frontends/cxd2820r_core.c
@@ -584,18 +584,14 @@ static int cxd2820r_get_frontend_algo(struct dvb_frontend *fe)
 static void cxd2820r_release(struct dvb_frontend *fe)
 {
 	struct cxd2820r_priv *priv = fe->demodulator_priv;
-	int uninitialized_var(ret); /* silence compiler warning */
 
 	dev_dbg(&priv->i2c->dev, "%s\n", __func__);
 
 #ifdef CONFIG_GPIOLIB
 	/* remove GPIOs */
-	if (priv->gpio_chip.label) {
-		ret = gpiochip_remove(&priv->gpio_chip);
-		if (ret)
-			dev_err(&priv->i2c->dev, "%s: gpiochip_remove() " \
-					"failed=%d\n", KBUILD_MODNAME, ret);
-	}
+	if (priv->gpio_chip.label)
+		gpiochip_remove(&priv->gpio_chip);
+
 #endif
 	kfree(priv);
 	return;
diff --git a/drivers/mfd/asic3.c b/drivers/mfd/asic3.c
index 9f6294f..8a968f9 100644
--- a/drivers/mfd/asic3.c
+++ b/drivers/mfd/asic3.c
@@ -605,7 +605,8 @@ static int asic3_gpio_remove(struct platform_device *pdev)
 {
 	struct asic3 *asic = platform_get_drvdata(pdev);
 
-	return gpiochip_remove(&asic->gpio);
+	gpiochip_remove(&asic->gpio);
+	return 0;
 }
 
 static void asic3_clk_enable(struct asic3 *asic, struct asic3_clk *clk)
diff --git a/drivers/mfd/htc-i2cpld.c b/drivers/mfd/htc-i2cpld.c
index d7b2a75..4306329 100644
--- a/drivers/mfd/htc-i2cpld.c
+++ b/drivers/mfd/htc-i2cpld.c
@@ -486,15 +486,9 @@ static int htcpld_register_chip_gpio(
 
 	ret = gpiochip_add(&(chip->chip_in));
 	if (ret) {
-		int error;
-
 		dev_warn(dev, "Unable to register input GPIOs for 0x%x: %d\n",
 			 plat_chip_data->addr, ret);
-
-		error = gpiochip_remove(&(chip->chip_out));
-		if (error)
-			dev_warn(dev, "Error while trying to unregister gpio chip: %d\n", error);
-
+		gpiochip_remove(&(chip->chip_out));
 		return ret;
 	}
 
diff --git a/drivers/mfd/sm501.c b/drivers/mfd/sm501.c
index e7dc441..d37b611 100644
--- a/drivers/mfd/sm501.c
+++ b/drivers/mfd/sm501.c
@@ -1047,7 +1047,6 @@ static int sm501_register_gpio(struct sm501_devdata *sm)
 	struct sm501_gpio *gpio = &sm->gpio;
 	resource_size_t iobase = sm->io_res->start + SM501_GPIO;
 	int ret;
-	int tmp;
 
 	dev_dbg(sm->dev, "registering gpio block %08llx\n",
 		(unsigned long long)iobase);
@@ -1086,11 +1085,7 @@ static int sm501_register_gpio(struct sm501_devdata *sm)
 	return 0;
 
  err_low_chip:
-	tmp = gpiochip_remove(&gpio->low.gpio);
-	if (tmp) {
-		dev_err(sm->dev, "cannot remove low chip, cannot tidy up\n");
-		return ret;
-	}
+	gpiochip_remove(&gpio->low.gpio);
 
  err_mapped:
 	iounmap(gpio->regs);
@@ -1105,18 +1100,12 @@ static int sm501_register_gpio(struct sm501_devdata *sm)
 static void sm501_gpio_remove(struct sm501_devdata *sm)
 {
 	struct sm501_gpio *gpio = &sm->gpio;
-	int ret;
 
 	if (!sm->gpio.registered)
 		return;
 
-	ret = gpiochip_remove(&gpio->low.gpio);
-	if (ret)
-		dev_err(sm->dev, "cannot remove low chip, cannot tidy up\n");
-
-	ret = gpiochip_remove(&gpio->high.gpio);
-	if (ret)
-		dev_err(sm->dev, "cannot remove high chip, cannot tidy up\n");
+	gpiochip_remove(&gpio->low.gpio);
+	gpiochip_remove(&gpio->high.gpio);
 
 	iounmap(gpio->regs);
 	release_resource(gpio->regs_res);
diff --git a/drivers/mfd/tc6393xb.c b/drivers/mfd/tc6393xb.c
index 11c19e5..4fac16b 100644
--- a/drivers/mfd/tc6393xb.c
+++ b/drivers/mfd/tc6393xb.c
@@ -607,7 +607,7 @@ static int tc6393xb_probe(struct platform_device *dev)
 	struct tc6393xb_platform_data *tcpd = dev_get_platdata(&dev->dev);
 	struct tc6393xb *tc6393xb;
 	struct resource *iomem, *rscr;
-	int ret, temp;
+	int ret;
 
 	iomem = platform_get_resource(dev, IORESOURCE_MEM, 0);
 	if (!iomem)
@@ -714,7 +714,7 @@ err_setup:
 
 err_gpio_add:
 	if (tc6393xb->gpio.base != -1)
-		temp = gpiochip_remove(&tc6393xb->gpio);
+		gpiochip_remove(&tc6393xb->gpio);
 	tcpd->disable(dev);
 err_enable:
 	clk_disable(tc6393xb->clk);
@@ -744,13 +744,8 @@ static int tc6393xb_remove(struct platform_device *dev)
 
 	tc6393xb_detach_irq(dev);
 
-	if (tc6393xb->gpio.base != -1) {
-		ret = gpiochip_remove(&tc6393xb->gpio);
-		if (ret) {
-			dev_err(&dev->dev, "Can't remove gpio chip: %d\n", ret);
-			return ret;
-		}
-	}
+	if (tc6393xb->gpio.base != -1)
+		gpiochip_remove(&tc6393xb->gpio);
 
 	ret = tcpd->disable(dev);
 	clk_disable(tc6393xb->clk);
diff --git a/drivers/mfd/ucb1x00-core.c b/drivers/mfd/ucb1x00-core.c
index 153d595..58ea9fd 100644
--- a/drivers/mfd/ucb1x00-core.c
+++ b/drivers/mfd/ucb1x00-core.c
@@ -621,7 +621,6 @@ static void ucb1x00_remove(struct mcp *mcp)
 	struct ucb1x00_plat_data *pdata = mcp->attached_device.platform_data;
 	struct ucb1x00 *ucb = mcp_get_drvdata(mcp);
 	struct list_head *l, *n;
-	int ret;
 
 	mutex_lock(&ucb1x00_mutex);
 	list_del(&ucb->node);
@@ -631,11 +630,8 @@ static void ucb1x00_remove(struct mcp *mcp)
 	}
 	mutex_unlock(&ucb1x00_mutex);
 
-	if (ucb->gpio.base != -1) {
-		ret = gpiochip_remove(&ucb->gpio);
-		if (ret)
-			dev_err(&ucb->dev, "Can't remove gpio chip: %d\n", ret);
-	}
+	if (ucb->gpio.base != -1)
+		gpiochip_remove(&ucb->gpio);
 
 	irq_set_chained_handler(ucb->irq, NULL);
 	irq_free_descs(ucb->irq_base, 16);
diff --git a/drivers/pinctrl/pinctrl-abx500.c b/drivers/pinctrl/pinctrl-abx500.c
index 163da9c..7dc9804 100644
--- a/drivers/pinctrl/pinctrl-abx500.c
+++ b/drivers/pinctrl/pinctrl-abx500.c
@@ -1221,7 +1221,7 @@ static int abx500_gpio_probe(struct platform_device *pdev)
 	const struct of_device_id *match;
 	struct abx500_pinctrl *pct;
 	unsigned int id = -1;
-	int ret, err;
+	int ret;
 	int i;
 
 	if (!np) {
@@ -1313,10 +1313,7 @@ static int abx500_gpio_probe(struct platform_device *pdev)
 	return 0;
 
 out_rem_chip:
-	err = gpiochip_remove(&pct->chip);
-	if (err)
-		dev_info(&pdev->dev, "failed to remove gpiochip\n");
-
+	gpiochip_remove(&pct->chip);
 	return ret;
 }
 
@@ -1327,14 +1324,8 @@ out_rem_chip:
 static int abx500_gpio_remove(struct platform_device *pdev)
 {
 	struct abx500_pinctrl *pct = platform_get_drvdata(pdev);
-	int ret;
 
-	ret = gpiochip_remove(&pct->chip);
-	if (ret < 0) {
-		dev_err(pct->dev, "unable to remove gpiochip: %d\n",
-			ret);
-		return ret;
-	}
+	gpiochip_remove(&pct->chip);
 
 	return 0;
 }
diff --git a/drivers/pinctrl/pinctrl-adi2.c b/drivers/pinctrl/pinctrl-adi2.c
index 0cc0eec..af426ea 100644
--- a/drivers/pinctrl/pinctrl-adi2.c
+++ b/drivers/pinctrl/pinctrl-adi2.c
@@ -979,7 +979,7 @@ static int adi_gpio_probe(struct platform_device *pdev)
 	struct gpio_port *port;
 	char pinctrl_devname[DEVNAME_SIZE];
 	static int gpio;
-	int ret = 0, ret1;
+	int ret = 0;
 
 	pdata = dev->platform_data;
 	if (!pdata)
@@ -1057,7 +1057,7 @@ static int adi_gpio_probe(struct platform_device *pdev)
 	return 0;
 
 out_remove_gpiochip:
-	ret1 = gpiochip_remove(&port->chip);
+	gpiochip_remove(&port->chip);
 out_remove_domain:
 	if (port->pint)
 		irq_domain_remove(port->domain);
@@ -1068,12 +1068,11 @@ out_remove_domain:
 static int adi_gpio_remove(struct platform_device *pdev)
 {
 	struct gpio_port *port = platform_get_drvdata(pdev);
-	int ret;
 	u8 offset;
 
 	list_del(&port->node);
 	gpiochip_remove_pin_ranges(&port->chip);
-	ret = gpiochip_remove(&port->chip);
+	gpiochip_remove(&port->chip);
 	if (port->pint) {
 		for (offset = 0; offset < port->width; offset++)
 			irq_dispose_mapping(irq_find_mapping(port->domain,
@@ -1081,7 +1080,7 @@ static int adi_gpio_remove(struct platform_device *pdev)
 		irq_domain_remove(port->domain);
 	}
 
-	return ret;
+	return 0;
 }
 
 static int adi_pinctrl_probe(struct platform_device *pdev)
diff --git a/drivers/pinctrl/pinctrl-as3722.c b/drivers/pinctrl/pinctrl-as3722.c
index c862f9c0..0e4ec91 100644
--- a/drivers/pinctrl/pinctrl-as3722.c
+++ b/drivers/pinctrl/pinctrl-as3722.c
@@ -565,7 +565,6 @@ static int as3722_pinctrl_probe(struct platform_device *pdev)
 {
 	struct as3722_pctrl_info *as_pci;
 	int ret;
-	int tret;
 
 	as_pci = devm_kzalloc(&pdev->dev, sizeof(*as_pci), GFP_KERNEL);
 	if (!as_pci)
@@ -611,10 +610,7 @@ static int as3722_pinctrl_probe(struct platform_device *pdev)
 	return 0;
 
 fail_range_add:
-	tret = gpiochip_remove(&as_pci->gpio_chip);
-	if (tret < 0)
-		dev_warn(&pdev->dev, "Couldn't remove gpio chip, %d\n", tret);
-
+	gpiochip_remove(&as_pci->gpio_chip);
 fail_chip_add:
 	pinctrl_unregister(as_pci->pctl);
 	return ret;
@@ -623,11 +619,8 @@ fail_chip_add:
 static int as3722_pinctrl_remove(struct platform_device *pdev)
 {
 	struct as3722_pctrl_info *as_pci = platform_get_drvdata(pdev);
-	int ret;
 
-	ret = gpiochip_remove(&as_pci->gpio_chip);
-	if (ret < 0)
-		return ret;
+	gpiochip_remove(&as_pci->gpio_chip);
 	pinctrl_unregister(as_pci->pctl);
 	return 0;
 }
diff --git a/drivers/pinctrl/pinctrl-baytrail.c b/drivers/pinctrl/pinctrl-baytrail.c
index 6e8301f..e9bc4d7 100644
--- a/drivers/pinctrl/pinctrl-baytrail.c
+++ b/drivers/pinctrl/pinctrl-baytrail.c
@@ -579,12 +579,9 @@ MODULE_DEVICE_TABLE(acpi, byt_gpio_acpi_match);
 static int byt_gpio_remove(struct platform_device *pdev)
 {
 	struct byt_gpio *vg = platform_get_drvdata(pdev);
-	int err;
 
 	pm_runtime_disable(&pdev->dev);
-	err = gpiochip_remove(&vg->chip);
-	if (err)
-		dev_warn(&pdev->dev, "failed to remove gpio_chip.\n");
+	gpiochip_remove(&vg->chip);
 
 	return 0;
 }
diff --git a/drivers/pinctrl/pinctrl-coh901.c b/drivers/pinctrl/pinctrl-coh901.c
index d182fdd..29cbbab 100644
--- a/drivers/pinctrl/pinctrl-coh901.c
+++ b/drivers/pinctrl/pinctrl-coh901.c
@@ -756,8 +756,7 @@ static int __init u300_gpio_probe(struct platform_device *pdev)
 
 err_no_range:
 err_no_irqchip:
-	if (gpiochip_remove(&gpio->chip))
-		dev_err(&pdev->dev, "failed to remove gpio chip\n");
+	gpiochip_remove(&gpio->chip);
 err_no_chip:
 	clk_disable_unprepare(gpio->clk);
 	dev_err(&pdev->dev, "module ERROR:%d\n", err);
@@ -767,16 +766,11 @@ err_no_chip:
 static int __exit u300_gpio_remove(struct platform_device *pdev)
 {
 	struct u300_gpio *gpio = platform_get_drvdata(pdev);
-	int err;
 
 	/* Turn off the GPIO block */
 	writel(0x00000000U, gpio->base + U300_GPIO_CR);
 
-	err = gpiochip_remove(&gpio->chip);
-	if (err < 0) {
-		dev_err(gpio->dev, "unable to remove gpiochip: %d\n", err);
-		return err;
-	}
+	gpiochip_remove(&gpio->chip);
 	clk_disable_unprepare(gpio->clk);
 	return 0;
 }
diff --git a/drivers/pinctrl/pinctrl-exynos5440.c b/drivers/pinctrl/pinctrl-exynos5440.c
index 8fe2ab0..648c600 100644
--- a/drivers/pinctrl/pinctrl-exynos5440.c
+++ b/drivers/pinctrl/pinctrl-exynos5440.c
@@ -881,11 +881,7 @@ static int exynos5440_gpiolib_register(struct platform_device *pdev,
 static int exynos5440_gpiolib_unregister(struct platform_device *pdev,
 				struct exynos5440_pinctrl_priv_data *priv)
 {
-	int ret = gpiochip_remove(priv->gc);
-	if (ret) {
-		dev_err(&pdev->dev, "gpio chip remove failed\n");
-		return ret;
-	}
+	gpiochip_remove(priv->gc);
 	return 0;
 }
 
diff --git a/drivers/pinctrl/pinctrl-msm.c b/drivers/pinctrl/pinctrl-msm.c
index e43fbce..35c6d32 100644
--- a/drivers/pinctrl/pinctrl-msm.c
+++ b/drivers/pinctrl/pinctrl-msm.c
@@ -864,7 +864,6 @@ static int msm_gpio_init(struct msm_pinctrl *pctrl)
 	int irq;
 	int ret;
 	int i;
-	int r;
 	unsigned ngpio = pctrl->soc->ngpios;
 
 	if (WARN_ON(ngpio > MAX_NR_GPIO))
@@ -894,7 +893,7 @@ static int msm_gpio_init(struct msm_pinctrl *pctrl)
 					      &irq_domain_simple_ops, NULL);
 	if (!pctrl->domain) {
 		dev_err(pctrl->dev, "Failed to register irq domain\n");
-		r = gpiochip_remove(&pctrl->chip);
+		gpiochip_remove(&pctrl->chip);
 		return -ENOSYS;
 	}
 
@@ -966,14 +965,8 @@ EXPORT_SYMBOL(msm_pinctrl_probe);
 int msm_pinctrl_remove(struct platform_device *pdev)
 {
 	struct msm_pinctrl *pctrl = platform_get_drvdata(pdev);
-	int ret;
-
-	ret = gpiochip_remove(&pctrl->chip);
-	if (ret) {
-		dev_err(&pdev->dev, "Failed to remove gpiochip\n");
-		return ret;
-	}
 
+	gpiochip_remove(&pctrl->chip);
 	irq_set_chained_handler(pctrl->irq, NULL);
 	irq_domain_remove(pctrl->domain);
 	pinctrl_unregister(pctrl->pctrl);
diff --git a/drivers/pinctrl/pinctrl-nomadik.c b/drivers/pinctrl/pinctrl-nomadik.c
index 8f6f16e..98c5ce2 100644
--- a/drivers/pinctrl/pinctrl-nomadik.c
+++ b/drivers/pinctrl/pinctrl-nomadik.c
@@ -1261,7 +1261,7 @@ static int nmk_gpio_probe(struct platform_device *dev)
 				   IRQ_TYPE_EDGE_FALLING);
 	if (ret) {
 		dev_err(&dev->dev, "could not add irqchip\n");
-		ret = gpiochip_remove(&nmk_chip->chip);
+		gpiochip_remove(&nmk_chip->chip);
 		return -ENODEV;
 	}
 	/* Then register the chain on the parent IRQ */
diff --git a/drivers/pinctrl/pinctrl-rockchip.c b/drivers/pinctrl/pinctrl-rockchip.c
index 96c60d2..707d9a7 100644
--- a/drivers/pinctrl/pinctrl-rockchip.c
+++ b/drivers/pinctrl/pinctrl-rockchip.c
@@ -1335,10 +1335,7 @@ fail:
 	for (--i, --bank; i >= 0; --i, --bank) {
 		if (!bank->valid)
 			continue;
-
-		if (gpiochip_remove(&bank->gpio_chip))
-			dev_err(&pdev->dev, "gpio chip %s remove failed\n",
-							bank->gpio_chip.label);
+		gpiochip_remove(&bank->gpio_chip);
 	}
 	return ret;
 }
@@ -1348,20 +1345,15 @@ static int rockchip_gpiolib_unregister(struct platform_device *pdev,
 {
 	struct rockchip_pin_ctrl *ctrl = info->ctrl;
 	struct rockchip_pin_bank *bank = ctrl->pin_banks;
-	int ret = 0;
 	int i;
 
-	for (i = 0; !ret && i < ctrl->nr_banks; ++i, ++bank) {
+	for (i = 0; i < ctrl->nr_banks; ++i, ++bank) {
 		if (!bank->valid)
 			continue;
-
-		ret = gpiochip_remove(&bank->gpio_chip);
+		gpiochip_remove(&bank->gpio_chip);
 	}
 
-	if (ret)
-		dev_err(&pdev->dev, "gpio chip remove failed\n");
-
-	return ret;
+	return 0;
 }
 
 static int rockchip_get_bank_data(struct rockchip_pin_bank *bank,
diff --git a/drivers/pinctrl/pinctrl-samsung.c b/drivers/pinctrl/pinctrl-samsung.c
index 0324d4c..4d0f2f7 100644
--- a/drivers/pinctrl/pinctrl-samsung.c
+++ b/drivers/pinctrl/pinctrl-samsung.c
@@ -841,9 +841,7 @@ static int samsung_gpiolib_register(struct platform_device *pdev,
 
 fail:
 	for (--i, --bank; i >= 0; --i, --bank)
-		if (gpiochip_remove(&bank->gpio_chip))
-			dev_err(&pdev->dev, "gpio chip %s remove failed\n",
-							bank->gpio_chip.label);
+		gpiochip_remove(&bank->gpio_chip);
 	return ret;
 }
 
@@ -853,16 +851,12 @@ static int samsung_gpiolib_unregister(struct platform_device *pdev,
 {
 	struct samsung_pin_ctrl *ctrl = drvdata->ctrl;
 	struct samsung_pin_bank *bank = ctrl->pin_banks;
-	int ret = 0;
 	int i;
 
-	for (i = 0; !ret && i < ctrl->nr_banks; ++i, ++bank)
-		ret = gpiochip_remove(&bank->gpio_chip);
+	for (i = 0; i < ctrl->nr_banks; ++i, ++bank)
+		gpiochip_remove(&bank->gpio_chip);
 
-	if (ret)
-		dev_err(&pdev->dev, "gpio chip remove failed\n");
-
-	return ret;
+	return 0;
 }
 
 static const struct of_device_id samsung_pinctrl_dt_match[];
diff --git a/drivers/pinctrl/pinctrl-sunxi.c b/drivers/pinctrl/pinctrl-sunxi.c
index f9fabe9..82cb34f 100644
--- a/drivers/pinctrl/pinctrl-sunxi.c
+++ b/drivers/pinctrl/pinctrl-sunxi.c
@@ -916,8 +916,7 @@ static int sunxi_pinctrl_probe(struct platform_device *pdev)
 	return 0;
 
 gpiochip_error:
-	if (gpiochip_remove(pctl->chip))
-		dev_err(&pdev->dev, "failed to remove gpio chip\n");
+	gpiochip_remove(pctl->chip);
 pinctrl_error:
 	pinctrl_unregister(pctl->pctl_dev);
 	return ret;
diff --git a/drivers/pinctrl/sh-pfc/gpio.c b/drivers/pinctrl/sh-pfc/gpio.c
index a9288ab..80f641e 100644
--- a/drivers/pinctrl/sh-pfc/gpio.c
+++ b/drivers/pinctrl/sh-pfc/gpio.c
@@ -409,11 +409,8 @@ int sh_pfc_register_gpiochip(struct sh_pfc *pfc)
 
 int sh_pfc_unregister_gpiochip(struct sh_pfc *pfc)
 {
-	int err;
-	int ret;
-
-	ret = gpiochip_remove(&pfc->gpio->gpio_chip);
-	err = gpiochip_remove(&pfc->func->gpio_chip);
+	gpiochip_remove(&pfc->gpio->gpio_chip);
+	gpiochip_remove(&pfc->func->gpio_chip);
 
-	return ret < 0 ? ret : err;
+	return 0;
 }
diff --git a/drivers/pinctrl/spear/pinctrl-plgpio.c b/drivers/pinctrl/spear/pinctrl-plgpio.c
index ff2940e..554c0a3 100644
--- a/drivers/pinctrl/spear/pinctrl-plgpio.c
+++ b/drivers/pinctrl/spear/pinctrl-plgpio.c
@@ -627,8 +627,7 @@ static int plgpio_probe(struct platform_device *pdev)
 
 remove_gpiochip:
 	dev_info(&pdev->dev, "Remove gpiochip\n");
-	if (gpiochip_remove(&plgpio->chip))
-		dev_err(&pdev->dev, "unable to remove gpiochip\n");
+	gpiochip_remove(&plgpio->chip);
 unprepare_clk:
 	if (!IS_ERR(plgpio->clk))
 		clk_unprepare(plgpio->clk);
diff --git a/drivers/pinctrl/vt8500/pinctrl-wmt.c b/drivers/pinctrl/vt8500/pinctrl-wmt.c
index 9802b67..3a72b6d 100644
--- a/drivers/pinctrl/vt8500/pinctrl-wmt.c
+++ b/drivers/pinctrl/vt8500/pinctrl-wmt.c
@@ -626,8 +626,7 @@ int wmt_pinctrl_probe(struct platform_device *pdev,
 	return 0;
 
 fail_range:
-	if (gpiochip_remove(&data->gpio_chip))
-		dev_err(&pdev->dev, "failed to remove gpio chip\n");
+	gpiochip_remove(&data->gpio_chip);
 fail_gpio:
 	pinctrl_unregister(data->pctl_dev);
 	return err;
@@ -636,12 +635,8 @@ fail_gpio:
 int wmt_pinctrl_remove(struct platform_device *pdev)
 {
 	struct wmt_pinctrl_data *data = platform_get_drvdata(pdev);
-	int err;
-
-	err = gpiochip_remove(&data->gpio_chip);
-	if (err)
-		dev_err(&pdev->dev, "failed to remove gpio chip\n");
 
+	gpiochip_remove(&data->gpio_chip);
 	pinctrl_unregister(data->pctl_dev);
 
 	return 0;
diff --git a/drivers/platform/x86/intel_pmic_gpio.c b/drivers/platform/x86/intel_pmic_gpio.c
index 2805988..478c3a5 100644
--- a/drivers/platform/x86/intel_pmic_gpio.c
+++ b/drivers/platform/x86/intel_pmic_gpio.c
@@ -301,8 +301,7 @@ static int platform_pmic_gpio_probe(struct platform_device *pdev)
 	return 0;
 
 fail_request_irq:
-	if (gpiochip_remove(&pg->chip))
-		pr_err("gpiochip_remove failed\n");
+	gpiochip_remove(&pg->chip);
 err:
 	iounmap(pg->gpiointr);
 err2:
diff --git a/drivers/ssb/driver_gpio.c b/drivers/ssb/driver_gpio.c
index ba350d2..f92e266 100644
--- a/drivers/ssb/driver_gpio.c
+++ b/drivers/ssb/driver_gpio.c
@@ -475,7 +475,8 @@ int ssb_gpio_unregister(struct ssb_bus *bus)
 {
 	if (ssb_chipco_available(&bus->chipco) ||
 	    ssb_extif_available(&bus->extif)) {
-		return gpiochip_remove(&bus->gpio);
+		gpiochip_remove(&bus->gpio);
+		return 0;
 	} else {
 		SSB_WARN_ON(1);
 	}
diff --git a/drivers/staging/vme/devices/vme_pio2_gpio.c b/drivers/staging/vme/devices/vme_pio2_gpio.c
index 2a2d920..3068288 100644
--- a/drivers/staging/vme/devices/vme_pio2_gpio.c
+++ b/drivers/staging/vme/devices/vme_pio2_gpio.c
@@ -221,9 +221,7 @@ void pio2_gpio_exit(struct pio2_card *card)
 {
 	const char *label = card->gc.label;
 
-	if (gpiochip_remove(&(card->gc)))
-		dev_err(&card->vdev->dev, "Failed to remove GPIO");
-
+	gpiochip_remove(&(card->gc));
 	kfree(label);
 }
 
diff --git a/drivers/tty/serial/max310x.c b/drivers/tty/serial/max310x.c
index 2a99d0c..740171b 100644
--- a/drivers/tty/serial/max310x.c
+++ b/drivers/tty/serial/max310x.c
@@ -1249,7 +1249,7 @@ static int max310x_probe(struct device *dev, struct max310x_devtype *devtype,
 	mutex_destroy(&s->mutex);
 
 #ifdef CONFIG_GPIOLIB
-	WARN_ON(gpiochip_remove(&s->gpio));
+	gpiochip_remove(&s->gpio);
 
 out_uart:
 #endif
@@ -1264,12 +1264,10 @@ out_clk:
 static int max310x_remove(struct device *dev)
 {
 	struct max310x_port *s = dev_get_drvdata(dev);
-	int i, ret = 0;
+	int i;
 
 #ifdef CONFIG_GPIOLIB
-	ret = gpiochip_remove(&s->gpio);
-	if (ret)
-		return ret;
+	gpiochip_remove(&s->gpio);
 #endif
 
 	for (i = 0; i < s->uart.nr; i++) {
@@ -1283,7 +1281,7 @@ static int max310x_remove(struct device *dev)
 	uart_unregister_driver(&s->uart);
 	clk_disable_unprepare(s->clk);
 
-	return ret;
+	return 0;
 }
 
 static const struct of_device_id __maybe_unused max310x_dt_ids[] = {
diff --git a/drivers/video/fbdev/via/via-gpio.c b/drivers/video/fbdev/via/via-gpio.c
index e408679..6f433b8 100644
--- a/drivers/video/fbdev/via/via-gpio.c
+++ b/drivers/video/fbdev/via/via-gpio.c
@@ -270,7 +270,7 @@ static int viafb_gpio_probe(struct platform_device *platdev)
 static int viafb_gpio_remove(struct platform_device *platdev)
 {
 	unsigned long flags;
-	int ret = 0, i;
+	int i;
 
 #ifdef CONFIG_PM
 	viafb_pm_unregister(&viafb_gpio_pm_hooks);
@@ -280,11 +280,7 @@ static int viafb_gpio_remove(struct platform_device *platdev)
 	 * Get unregistered.
 	 */
 	if (viafb_gpio_config.gpio_chip.ngpio > 0) {
-		ret = gpiochip_remove(&viafb_gpio_config.gpio_chip);
-		if (ret) { /* Somebody still using it? */
-			printk(KERN_ERR "Viafb: GPIO remove failed\n");
-			return ret;
-		}
+		gpiochip_remove(&viafb_gpio_config.gpio_chip);
 	}
 	/*
 	 * Disable the ports.
@@ -294,7 +290,7 @@ static int viafb_gpio_remove(struct platform_device *platdev)
 		viafb_gpio_disable(viafb_gpio_config.active_gpios[i]);
 	viafb_gpio_config.gpio_chip.ngpio = 0;
 	spin_unlock_irqrestore(&viafb_gpio_config.vdev->reg_lock, flags);
-	return ret;
+	return 0;
 }
 
 static struct platform_driver via_gpio_driver = {
diff --git a/sound/soc/codecs/wm5100.c b/sound/soc/codecs/wm5100.c
index eca983f..b526e5f 100644
--- a/sound/soc/codecs/wm5100.c
+++ b/sound/soc/codecs/wm5100.c
@@ -2320,11 +2320,8 @@ static void wm5100_init_gpio(struct i2c_client *i2c)
 static void wm5100_free_gpio(struct i2c_client *i2c)
 {
 	struct wm5100_priv *wm5100 = i2c_get_clientdata(i2c);
-	int ret;
 
-	ret = gpiochip_remove(&wm5100->gpio_chip);
-	if (ret != 0)
-		dev_err(&i2c->dev, "Failed to remove GPIOs: %d\n", ret);
+	gpiochip_remove(&wm5100->gpio_chip);
 }
 #else
 static void wm5100_init_gpio(struct i2c_client *i2c)
diff --git a/sound/soc/codecs/wm8903.c b/sound/soc/codecs/wm8903.c
index b0084a1..0737af8 100644
--- a/sound/soc/codecs/wm8903.c
+++ b/sound/soc/codecs/wm8903.c
@@ -1878,11 +1878,7 @@ static void wm8903_init_gpio(struct wm8903_priv *wm8903)
 
 static void wm8903_free_gpio(struct wm8903_priv *wm8903)
 {
-	int ret;
-
-	ret = gpiochip_remove(&wm8903->gpio_chip);
-	if (ret != 0)
-		dev_err(wm8903->dev, "Failed to remove GPIOs: %d\n", ret);
+	gpiochip_remove(&wm8903->gpio_chip);
 }
 #else
 static void wm8903_init_gpio(struct wm8903_priv *wm8903)
diff --git a/sound/soc/codecs/wm8962.c b/sound/soc/codecs/wm8962.c
index 5522d25..41caf4c 100644
--- a/sound/soc/codecs/wm8962.c
+++ b/sound/soc/codecs/wm8962.c
@@ -3400,11 +3400,8 @@ static void wm8962_init_gpio(struct snd_soc_codec *codec)
 static void wm8962_free_gpio(struct snd_soc_codec *codec)
 {
 	struct wm8962_priv *wm8962 = snd_soc_codec_get_drvdata(codec);
-	int ret;
 
-	ret = gpiochip_remove(&wm8962->gpio_chip);
-	if (ret != 0)
-		dev_err(codec->dev, "Failed to remove GPIOs: %d\n", ret);
+	gpiochip_remove(&wm8962->gpio_chip);
 }
 #else
 static void wm8962_init_gpio(struct snd_soc_codec *codec)
diff --git a/sound/soc/codecs/wm8996.c b/sound/soc/codecs/wm8996.c
index c6cbb3b..10ca2ad 100644
--- a/sound/soc/codecs/wm8996.c
+++ b/sound/soc/codecs/wm8996.c
@@ -2220,11 +2220,7 @@ static void wm8996_init_gpio(struct wm8996_priv *wm8996)
 
 static void wm8996_free_gpio(struct wm8996_priv *wm8996)
 {
-	int ret;
-
-	ret = gpiochip_remove(&wm8996->gpio_chip);
-	if (ret != 0)
-		dev_err(wm8996->dev, "Failed to remove GPIOs: %d\n", ret);
+	gpiochip_remove(&wm8996->gpio_chip);
 }
 #else
 static void wm8996_init_gpio(struct wm8996_priv *wm8996)
-- 
1.8.3.2
